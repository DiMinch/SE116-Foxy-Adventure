extends Node2D
class_name Stage

@export_group("Level Settings")
@export var level_id: int
@export var minute_limit: float = 5.0 # 5 minutes

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
var stage_layer: StageLayer = null
var water_area: Area2D

### CORE LOGIC ###
func _enter_tree() -> void:
	GameManager.current_stage = self

func _ready() -> void:
	_init_water_area()
	_init_stage_layer()
	_setup_initial_state()
	_start_level_sequence()

func _init_water_area() -> void:
	if has_node("World/WaterArea2D"):
		water_area = $World/WaterArea2D
		water_area.body_entered.connect(_on_water_entered)
		water_area.body_exited.connect(_on_water_exited)

func _init_stage_layer():
	if has_node("StageLayer"):
		stage_layer = $StageLayer
		stage_layer.request_transition.connect(_transition_to_next_stage)
		stage_layer.get_node("ResultPopup").retry_pressed.connect(respawn_player)

func _setup_initial_state() -> void:
	GameManager.clear_levels()
	# Check completed
	var completed_levels = UserSystem.meta_data.get("levels_completed", {})
	_has_played_start_timeline = completed_levels.has(str(level_id))
	# Register Dialogic signals
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

### LEVEL SEQUENCES (OPENING) ###
func _start_level_sequence() -> void:
	# Opening cutscene
	if opening_cutscene_scene:
		if stage_layer:
			stage_layer.visible = false
			await _play_cutscene(opening_cutscene_scene)
	
	# Setup Game World
	if stage_layer:
		stage_layer.visible = true
	start_time = Time.get_ticks_msec() / 1000.0
	_handle_respawn()
	setup_level_lighting()
	# Play music
	if MusicManager and level_music:
		MusicManager.play_music(level_music)
	# Dialogues
	if start_timeline and not _has_played_start_timeline:
		Dialogic.start(start_timeline)
		_has_played_start_timeline = true
	elif ambient_timeline and not _has_played_ambient:
		_trigger_ambient_delayed()

func _handle_respawn() -> void:
	if GameManager.respawn_at_portal(): 
		return
	if GameManager.respawn_at_checkpoint():
		return
	GameManager.respawn_at_begin()

### COMPLETION FLOW (ENDING) ###
func complete_level(next_stage_path: String, next_door_name: String) -> void:
	if level_id == 0:
		_transition_to_next_stage(next_stage_path, next_door_name)
		return
	# Lock Player
	if GameManager.player:
		GameManager.player.set_physics_process(false)
		GameManager.player.velocity = Vector2.ZERO
		GameManager.player.is_dialogue_active = true
	# Ending cutscene
	if ending_cutscene_scene:
		if MusicManager:
			MusicManager.stop_music()
		await _play_cutscene(ending_cutscene_scene)
	
	# Calculate results
	var results = _calculate_results(next_stage_path, next_door_name)
	if stage_layer:
		stage_layer.show_result(true, results)

func _calculate_results(next_path: String, next_door: String) -> Dictionary:
	# Calculate completed time
	var elapsed_time = Time.get_ticks_msec() / 1000.0 - start_time
	var time_bonus = max(0, int((minute_limit * 60 - elapsed_time) / 30))
	var collected = GameManager.inventory_system.get_currency("coins")
	var total_coins = collected + time_bonus
	# Update data
	var results = GameManager.level_completed(level_id, elapsed_time, total_coins)
	results.merge({
		"extra_coins": time_bonus,
		"collected": collected,
		"next_stage": next_path,
		"next_door": next_door,
	})
	return results

### DEFEAT ###
func handle_player_failed(fail_reason: String) -> void:
	if level_id == 0:
		get_tree().reload_current_scene()
		return
	
	if GameManager.player:
		GameManager.player.set_physics_process(false)
		GameManager.player.velocity = Vector2.ZERO
		GameManager.player.is_dialogue_active = true
	
	var elapsed_time = Time.get_ticks_msec() / 1000.0 - start_time
	var collected = GameManager.inventory_system.get_currency("coins")
	
	var results = {
		"level_id": level_id,
		"elapsed_time": elapsed_time,
		"collected": collected,
		"fail_reason": fail_reason,
	}
	if stage_layer:
		stage_layer.show_result(false, results)

### DIALOGIC LOGIC ###
func _play_cutscene(scene: PackedScene) -> void:
	var cutscene = scene.instantiate()
	var canvas = CanvasLayer.new()
	canvas.layer = 0
	add_child(canvas)
	canvas.add_child(cutscene)
	
	if cutscene.has_signal("cutscene_finished"):
		await cutscene.cutscene_finished
	else:
		await get_tree().create_timer(1.5).timeout
	canvas.queue_free()

func _trigger_ambient_delayed() -> void:
	await get_tree().create_timer(1.0).timeout
	trigger_ambient_dialogue()

func trigger_ambient_dialogue():
	if _has_played_ambient or not ambient_timeline or not ambient_character or not GameManager.player:
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
		_trigger_ambient_delayed()

### ENVIRONMENT LOGIC ###
func _on_water_entered(body):
	if body is Player:
		body.is_in_water = true
		body.use_gravity = false
		# Add audio "underwater" or effect

func _on_water_exited(body):
	if body is Player:
		body.is_in_water = false
		body.use_gravity = true
		# Add audio "underwater" or effect

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

### HELPERS ###
func _transition_to_next_stage(next_stage_path: String, next_door_name: String):
	GameManager.change_stage(next_stage_path, next_door_name)

func respawn_player() -> void:
	if not GameManager.respawn_at_checkpoint():
		GameManager.respawn_at_begin()
	
	if GameManager.player:
		GameManager.player.set_physics_process(true)
		GameManager.player.is_dialogue_active = false
		GameManager.player._ready()

func _exit_tree():
	cleanup_dialogic()

func run_start_timeline():
	if start_timeline:
		Dialogic.start(start_timeline)
		_has_played_start_timeline = true

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
