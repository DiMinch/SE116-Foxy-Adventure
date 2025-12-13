extends Node2D

@export_file("*.tscn") var target_stage = ""
@export var target_door = "Door"

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready() -> void:
	sprite.play("closing")
	await sprite.animation_finished
	sprite.play("idle")

func _on_interactive_area_2d_interacted() -> void:
	AudioManager.play_sound("door")
	await open_and_transition()

func open_and_transition():
	var target_res := ResourceLoader.load(target_stage)
	
	if GameManager.current_stage.scene_file_path == target_res.resource_path:
		print("[Door] Teleported player to portal: %s in same scene" % target_door)
		_teleport_in_same_stage()
		return
	
	print("[Door] Different stage detected. Fading out and changing scene...")

	sprite.play("opening")
	await sprite.animation_finished
	await fade_screen(true)
	GameManager.change_stage(target_stage, target_door)
	sprite.play("closing")

func _teleport_in_same_stage() -> void:
	var target_portal = GameManager.current_stage.find_child(target_door)

	if target_portal == null:
		push_warning("[Door] Target door '%s' not found in current scene!" % target_door)
		return
	
	if GameManager.player == null:
		push_warning("[Door] Player not found in GameManager!")
		return
	
	sprite.play("opening")
	await sprite.animation_finished
	GameManager.player.global_position = target_portal.global_position
	sprite.play("closing")

func fade_screen(is_fade_out: bool) -> void:
	if not is_inside_tree():
		await ready

	var tree := get_tree()
	if tree == null:
		return

	var root := tree.root
	if root == null:
		return
	
	var fade_layer = get_tree().root.get_node_or_null("FadeLayer")
	if fade_layer == null:
		fade_layer = FadeLayer.new()
		root.add_child(fade_layer)

	if is_fade_out:
		await fade_layer.fade_out()
	else:
		await fade_layer.fade_in()
