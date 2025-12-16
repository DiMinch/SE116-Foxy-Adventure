extends Node2D
class_name Stage

@onready var turn_back_button = $CanvasLayer/TurnBack

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

func _enter_tree() -> void:
	GameManager.current_stage = self

func _ready() -> void:
	fade_in_screen()
	
	if opening_cutscene_scene:
		play_opening_cutscene_default()
	else:
		_on_opening_sequence_finished()

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
	print("Stage: Cutscene xong (hoặc không có), bắt đầu logic game")
	
	if turn_back_button:
		turn_back_button.pressed.connect(_on_turn_back_pressed)
	
	if GameManager.respawn_at_portal():
		print("Stage: Respawn tại Portal")
	elif GameManager.respawn_at_checkpoint():
		print("Stage: Respawn tại Checkpoint")
	else:
		print("Stage: Respawn tại Begin")
		GameManager.respawn_at_begin()
		
	setup_level_lighting()

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
	var fade_layer = get_tree().root.get_node_or_null("FadeLayer")
	if fade_layer:
		await fade_layer.fade_in()

func _on_turn_back_pressed():
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
	
	if ending_cutscene_scene:
		_play_ending_cutscene(next_stage_path, next_door_name)
	else:
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
	var fade_layer = get_tree().root.get_node_or_null("FadeLayer")
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
