extends Node2D
class_name Stage

@onready var turn_back_button = $CanvasLayer/TurnBack

func _enter_tree() -> void:
	# Handle portal spawning first
	GameManager.current_stage = self
	
func _ready() -> void:
	fade_in_screen()
	if turn_back_button:
		turn_back_button.pressed.connect(_on_turn_back_pressed)
	
	if GameManager.respawn_at_portal():
		return
	if GameManager.respawn_at_checkpoint():
		return
	GameManager.respawn_at_begin()

func fade_in_screen() -> void:
	var fade_layer = get_tree().root.get_node_or_null("FadeLayer")
	if fade_layer:
		await fade_layer.fade_in()

func _on_turn_back_pressed():
	get_tree().change_scene_to_file("res://scenes/game_screen/select_level_screen.tscn")
