extends CanvasLayer

@onready var game_start_btn: Button = $StartContainer/VBoxContainer/GameStart
@onready var start_container: Control = $StartContainer

func _ready() -> void:
	game_start_btn.pressed.connect(_on_game_start_pressed)
	if GameManager.has_started_session:
		_skip_started_menu()
	else:
		_pause_game()

func _skip_started_menu():
	get_tree().paused = false
	start_container.hide()

func _pause_game():
	get_tree().paused = true
	start_container.show()

func _on_game_start_pressed() -> void:
	print("Game Start clicked!")
	GameManager.has_started_session = true
	_skip_started_menu()
