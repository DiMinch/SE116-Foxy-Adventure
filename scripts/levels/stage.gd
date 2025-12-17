extends Node2D
class_name Stage

@export_group("Audio Settings")
@export var level_music: AudioStream
@export var boss_music: AudioStream

@export_group("Dialogic Settings")
@export var start_timeline: DialogicTimeline
@export var ambient_timeline: DialogicTimeline
@export var ambient_character: DialogicCharacter
@export var ambient_style_name: String = "bubble_style"

@export_group("Cutscenes")
@export var opening_cutscene_scene: PackedScene
@export var ending_cutscene_scene: PackedScene

@export_group("Visual Settings")
@export var is_dark_level: bool = false

var is_ambient_dialogue: bool = false
var _has_played_ambient: bool = false
var _has_played_start_timeline: bool = false

var start_time: float = 0.0 # Time start level
var _stage_ui: CanvasLayer = null

func _enter_tree() -> void:
	GameManager.current_stage = self

func _ready() -> void:
	_find_stage_ui()
	
	if opening_cutscene_scene:
		if _stage_ui:
			_stage_ui.visible = false
		play_opening_cutscene_default()
	else:
		_on_opening_sequence_finished()

func _find_stage_ui():
	if is_instance_valid(_stage_ui):
		return _stage_ui
	
	var found_ui = find_child("StageUI")
	if found_ui and found_ui is CanvasLayer:
		_stage_ui = found_ui as CanvasLayer
		return _stage_ui
	
	push_error("StageUI Node không tìm thấy là con của Stage. Hãy kiểm tra tên node StageUI.")
	return null

func _get_fade_layer() -> Node:
	if not is_instance_valid(_stage_ui):
		return null
	
	var fade_layer = _stage_ui.get_node_or_null("FadeLayer")
	
	if not fade_layer:
		push_error("Không tìm thấy FadeLayer bên trong StageUI. Hãy kiểm tra tên node FadeLayer.")
		
	return fade_layer

func play_opening_cutscene_default():
	var cutscene_instance = opening_cutscene_scene.instantiate()
	
	var canvas = CanvasLayer.new()
	canvas.layer = 0
	add_child(canvas)
	canvas.add_child(cutscene_instance)
	
	if cutscene_instance.has_signal("cutscene_finished"):
		cutscene_instance.cutscene_finished.connect(func():
			canvas.queue_free()
			_on_opening_sequence_finished()
		)
	else:
		push_error("Cutscene Scene thiếu signal 'cutscene_finished'!")
		_on_opening_sequence_finished()

func _on_opening_sequence_finished():
	if _stage_ui and not _stage_ui.visible:
		_stage_ui.visible = true
	
	start_time = Time.get_ticks_msec() / 1000.0
	
	print("Stage: Cutscene xong (hoặc không có), bắt đầu logic game")
	
	if GameManager.respawn_at_portal():
		print("Stage: Respawn tại Portal")
	elif GameManager.respawn_at_checkpoint():
		print("Stage: Respawn tại Checkpoint")
	else:
		print("Stage: Respawn tại Begin")
		GameManager.respawn_at_begin()
		
	setup_level_lighting()
	await fade_in_screen()

	if not Dialogic.timeline_started.is_connected(_on_timeline_started):
		Dialogic.timeline_started.connect(_on_timeline_started)
	if not Dialogic.timeline_ended.is_connected(_on_timeline_ended):
		Dialogic.timeline_ended.connect(_on_timeline_ended)
	
	if start_timeline and not _has_played_start_timeline:
		run_start_timeline()
	else:
		if ambient_timeline and not _has_played_ambient:
			await get_tree().create_timer(1.0).timeout
			trigger_ambient_dialogue()
		else:
			print("Stage: Không chạy ambient (Timeline null hoặc đã chơi)")

	if MusicManager and level_music:
		MusicManager.play_music(level_music)

func _exit_tree():
	cleanup_dialogic()

func run_start_timeline():
	if start_timeline:
		Dialogic.start(start_timeline)
		_has_played_start_timeline = true

func trigger_ambient_dialogue():
	if not ambient_timeline:
		return
	if not ambient_character:
		return
	if not GameManager.player:
		return
	if _has_played_ambient:
		return
		
	is_ambient_dialogue = true
	_has_played_ambient = true
	
	if MusicManager:
		MusicManager.play_music(level_music, true, -12.0, 1.0)
	var dialog_node = Dialogic.Styles.load_style(ambient_style_name)
	
	if dialog_node and dialog_node.has_method("register_character"):
		dialog_node.register_character(ambient_character, GameManager.player)
		Dialogic.start(ambient_timeline)
		
		Dialogic.Inputs.auto_advance.enabled_forced = true
		
		await get_tree().create_timer(1.0).timeout 
		Dialogic.Inputs.manual_advance.system_enabled = false
	else:
		print("[Stage] Lỗi: Không thể load style hoặc register_character cho Ambient Dialogue")

func cleanup_dialogic():
	if Dialogic.current_timeline != null:
		Dialogic.end_timeline()
	
	if Dialogic.timeline_started.is_connected(_on_timeline_started):
		Dialogic.timeline_started.disconnect(_on_timeline_started)
	if Dialogic.timeline_ended.is_connected(_on_timeline_ended):
		Dialogic.timeline_ended.disconnect(_on_timeline_ended)
	
	var dialog_node = Dialogic.Styles.get_layout_node()
	if dialog_node and dialog_node.has_method("unregister_character") and ambient_character:
		dialog_node.unregister_character(ambient_character)

func fade_in_screen() -> void:
	var fade_layer = _get_fade_layer()
	if fade_layer and fade_layer.has_method("fade_in"):
		await fade_layer.fade_in()
	else:
		push_warning("FadeLayer không có hàm fade_in hoặc không tồn tại.")

func _on_turn_back_pressed():
	var fade_layer = _get_fade_layer()
	if fade_layer and fade_layer.has_method("fade_out"):
		await fade_layer.fade_out()
	get_tree().change_scene_to_file("res://scenes/game_screen/select_level_screen.tscn")
	MusicManager.stop_music()

func _on_timeline_started():
	if GameManager.player and not is_ambient_dialogue:
		GameManager.player.is_dialogue_active = true
		GameManager.player.velocity = Vector2.ZERO
		GameManager.player.change_animation("idle")

func _on_timeline_ended():
	if GameManager.player:
		GameManager.player.is_dialogue_active = false
	
	if is_ambient_dialogue:
		is_ambient_dialogue = false
		Dialogic.Inputs.auto_advance.enabled_forced = false
		Dialogic.Inputs.manual_advance.system_enabled = true
		
		var bubbles = get_tree().get_nodes_in_group("dialogic_layout")
		for b in bubbles:
			b.queue_free()
	
	if _has_played_start_timeline and ambient_timeline and not is_ambient_dialogue and not _has_played_ambient:
		await get_tree().create_timer(1.0).timeout
		trigger_ambient_dialogue()
		
func complete_level(next_stage_path: String, next_door_name: String) -> void:
	print("Stage: Level Completed!")
	
	if GameManager.player:
		GameManager.player.set_physics_process(false)
		GameManager.player.velocity = Vector2.ZERO
	
	# Calculate completed time
	var end_time = Time.get_ticks_msec() / 1000.0
	var elapsed_time = end_time - start_time
	var level_id = self.scene_file_path
	
	# Total coins
	var collected_coins = GameManager.inventory_system.get_currency("coins")
	var bonus_reward = max(0, int(500.0 / elapsed_time))
	var total_coin_reward = collected_coins + bonus_reward
	
	# Handle logic game
	if PlayerData:
		PlayerData.player_coins += total_coin_reward
		PlayerData.coins_changed.emit(PlayerData.player_coins)
		PlayerData.save_upgrades()
	
	if UserSystem:
		UserSystem.record_level_completion(level_id, elapsed_time)
	
	if ending_cutscene_scene:
		_play_ending_cutscene(next_stage_path, next_door_name)
	else:
		print("Total coins: ", total_coin_reward)
		_transition_to_next_stage(next_stage_path, next_door_name)

func _play_ending_cutscene(next_stage_path: String, next_door_name: String):
	print("Stage: Playing Ending Cutscene...")
	var cutscene_instance = ending_cutscene_scene.instantiate()
	
	var canvas = CanvasLayer.new()
	canvas.layer = 0
	add_child(canvas)
	canvas.add_child(cutscene_instance)
	
	if cutscene_instance.has_signal("cutscene_finished"):
		cutscene_instance.cutscene_finished.connect(func():
			canvas.queue_free()
			_transition_to_next_stage(next_stage_path, next_door_name)
		)
	else:
		push_error("Ending Cutscene thiếu signal 'cutscene_finished'!")
		_transition_to_next_stage(next_stage_path, next_door_name)

func _transition_to_next_stage(next_stage_path: String, next_door_name: String):
	var fade_layer = _get_fade_layer()
	if fade_layer:
		await fade_layer.fade_out()
	
	GameManager.change_stage(next_stage_path, next_door_name)

func setup_level_lighting():
	if GameManager.player:
		var player_light = GameManager.player.get_node_or_null("PointLight2D")
		
		if player_light:
			player_light.enabled = is_dark_level
			player_light.visible = is_dark_level
			print("Stage: Đã %s đèn của Player" % ["BẬT" if is_dark_level else "TẮT"])
		else:
			if is_dark_level:
				push_warning("Stage: Level này tối nhưng Player chưa có PointLight2D!")
	
	var canvas_modulate = get_node_or_null("CanvasModulate")
	if canvas_modulate:
		canvas_modulate.visible = is_dark_level
