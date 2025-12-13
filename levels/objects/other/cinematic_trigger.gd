extends Area2D

@export_group("Cinematic Targets")
@export var target_node: Node2D
@export var boss_name: String = "KING CRAB"
@export var boss_title: String = "Terror of the Seas"

@export_group("VFX Settings")
@export var enable_shake: bool = true
@export var shake_power: float = 3.0
@export var block_player_input: bool = true

@onready var cinema_cam = $CinemaCamera
@onready var top_bar = $CinematicUI/TopBar
@onready var bottom_bar = $CinematicUI/BottomBar
@onready var speed_lines = $CinematicUI/SpeedLines
@onready var boss_card = $CinematicUI/BossCard
@onready var boss_label = $CinematicUI/BossCard/Label
@onready var cinema_ui = $CinematicUI

var is_triggered = false

func _ready():
	top_bar.scale.y = 0
	bottom_bar.scale.y = 0
	speed_lines.visible = false
	boss_card.modulate.a = 0
	cinema_ui.visible = false
	
	collision_mask = 2
	body_entered.connect(_on_body_entered)

func _on_body_entered(body):
	if is_triggered: return
	
	if body.is_in_group("Player") or body.name == "Player":
		start_cinematic_sequence(body)

func start_cinematic_sequence(player):
	is_triggered = true
	
	print("Cinematic started")
	print("Target node: ", target_node)
	print("Player: ", player)
	
	if block_player_input:
		if player.has_method("set_physics_process"):
			player.set_physics_process(false)
		
		if "velocity" in player:
			player.velocity = Vector2.ZERO

	# Setup Camera
	var main_cam = player.get_node_or_null("Camera2D")
	if main_cam:
		cinema_cam.global_position = main_cam.global_position
		cinema_cam.zoom = main_cam.zoom
		cinema_cam.enabled = true
		cinema_cam.make_current()
		print("Main camera found and switched")
	else:
		print("WARNING: No Camera2D found on player")

	cinema_ui.visible = true
	
	var tween = create_tween().set_parallel(true)
	
	tween.tween_property(top_bar, "scale:y", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(bottom_bar, "scale:y", 1.0, 0.5).set_trans(Tween.TRANS_CUBIC)
	
	speed_lines.visible = true
	
	await tween.finished
	
	if target_node:
		print("Panning camera to: ", target_node.global_position)
		var pan_tween = create_tween()
		pan_tween.tween_property(cinema_cam, "global_position", target_node.global_position, 1.2)\
			.set_trans(Tween.TRANS_EXPO).set_ease(Tween.EASE_OUT)
		await pan_tween.finished
	else:
		print("ERROR: target_node is null!")
	
	Engine.time_scale = 0.2
	speed_lines.visible = false
	
	if enable_shake:
		apply_camera_shake()
	
	# Hiện thông tin Boss
	boss_label.text = "[center]%s\n[font_size=24]%s[/font_size][/center]" % [boss_name, boss_title]
	
	var boss_tween = create_tween()
	boss_tween.tween_property(boss_card, "modulate:a", 1.0, 0.1)
	boss_tween.tween_interval(0.3)
	await boss_tween.finished
	
	# --- 5. TRƯỚC LẠI CAMERA ---
	Engine.time_scale = 1.0
	
	var return_tween = create_tween().set_parallel(true)
	return_tween.tween_property(boss_card, "modulate:a", 0.0, 0.5)
	return_tween.tween_property(cinema_cam, "global_position", player.global_position, 0.8)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	await return_tween.finished
	
	# --- 6. DỌN DẢP & MỞ KHÓA INPUT ---
	cinema_cam.enabled = false
	if main_cam: 
		main_cam.make_current()
	
	# Ẩn thanh đen
	var ui_tween = create_tween().set_parallel(true)
	ui_tween.tween_property(top_bar, "scale:y", 0.0, 0.5)
	ui_tween.tween_property(bottom_bar, "scale:y", 0.0, 0.5)
	await ui_tween.finished
	
	cinema_ui.visible = false
	
	# Mở khóa input
	if block_player_input and player.has_method("set_physics_process"):
		player.set_physics_process(true)
	
	queue_free()

func apply_camera_shake():
	var shake_tween = create_tween()
	for i in range(10):
		var random_offset = Vector2(
			randf_range(-shake_power, shake_power), 
			randf_range(-shake_power, shake_power)
		)
		shake_tween.tween_property(cinema_cam, "offset", random_offset, 0.05)
	
	shake_tween.chain().tween_property(cinema_cam, "offset", Vector2.ZERO, 0.05)
