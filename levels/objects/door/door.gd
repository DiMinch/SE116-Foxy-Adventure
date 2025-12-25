extends Node2D
class_name Door

@export_file("*.tscn") var target_stage = ""
@export var target_door = "Begin"
@export var unlocked_keys: int = 1

@onready var sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var f_label: Label = $FLabel

func _ready() -> void:
	sprite.play("closing")
	AudioManager.play_sound("door")

func can_open() -> bool:
	var current_keys = GameManager.inventory_system.get_currency("keys")
	return not current_keys < unlocked_keys

func _on_interactive_area_2d_interacted() -> void:
	if can_open():
		AudioManager.play_sound("door")
		await open_and_transition()
	else:
		print("[INFO] Player doesn't have key to open door!")

func _on_interactive_area_2d_interaction_available() -> void:
	if can_open():
		sprite.play("opening")
		AudioManager.play_sound("door")
		f_label.text = "[F]"
	else:
		f_label.text = "Need " + str(unlocked_keys) + " keys"
	f_label.visible = true

func _on_interactive_area_2d_interaction_unavailable() -> void:
	f_label.visible = false
	if sprite.animation == "opening" or sprite.animation == "idle":
		sprite.play("closing")
		AudioManager.play_sound("door")

func open_and_transition():
	f_label.visible = false
	var target_res := ResourceLoader.load(target_stage)
	
	if GameManager.current_stage.scene_file_path == target_res.resource_path:
		print("[Door] Teleported player within same scene")
		_teleport_in_same_stage()
		return
	
	print("[Door] Level Finished. Requesting stage completion...")
	if GameManager.current_stage.has_method("complete_level"):
		GameManager.current_stage.complete_level(target_stage, target_door)
	else:
		GameManager.change_stage(target_stage, target_door)

func _teleport_in_same_stage() -> void:
	var target_portal = GameManager.current_stage.find_child(target_door)

	if target_portal == null or GameManager.player == null:
		return
	
	sprite.play("opening")
	await sprite.animation_finished
	GameManager.player.global_position = target_portal.global_position
	
	if GameManager.current_stage.has_method("fade_in_screen"):
		await GameManager.current_stage.fade_in_screen()
	sprite.play("closing")
