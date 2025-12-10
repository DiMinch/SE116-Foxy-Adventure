extends Node2D
class_name Stage

@onready var turn_back_button = $CanvasLayer/TurnBack
var is_ambient_dialogue: bool = false

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
	Dialogic.timeline_started.connect(_on_timeline_started)
	Dialogic.timeline_ended.connect(_on_timeline_ended)

func fade_in_screen() -> void:
	var fade_layer = get_tree().root.get_node_or_null("FadeLayer")
	if fade_layer:
		await fade_layer.fade_in()

func _on_turn_back_pressed():
	get_tree().change_scene_to_file("res://scenes/game_screen/select_level_screen.tscn")

func _on_timeline_started():
	if GameManager.player and not is_ambient_dialogue:
		GameManager.player.is_dialogue_active = true
		GameManager.player.velocity = Vector2.ZERO
		GameManager.player.change_animation("idle")
		
		# Tùy chọn: Tạm thời vô hiệu hóa input Space của Dialogic để tránh lỗi trùng input
		# (Dialogic có cơ chế riêng, nhưng nếu muốn an toàn tuyệt đối thì tạm vô hiệu hóa)
		# Dialogic.Input.input_actions.erase("ui_accept") 
		
func _on_timeline_ended():
	if GameManager.player:
		GameManager.player.is_dialogue_active = false
	
	is_ambient_dialogue = false
