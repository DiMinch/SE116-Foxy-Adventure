extends CanvasLayer
class_name StageLayer

signal request_transition(stage_path, door_name)

@onready var victory_popup = $VictoryPopup
@onready var default_popup = $DefeatPopup
@onready var result_popup = $ResultPopup

func _ready() -> void:
	result_popup.next_level_pressed.connect(_on_next_level_pressed)

func _on_next_level_pressed(stage_path, door_name):
	request_transition.emit(stage_path, door_name)

func show_result(is_victory: bool, level_data: Dictionary):
	get_tree().paused = true
	if is_victory:
		victory_popup.show()
	else:
		default_popup.show()
	await get_tree().create_timer(2.0).timeout
	
	victory_popup.hide()
	default_popup.hide()
	_setup_result_popup(is_victory, level_data)
	result_popup.show()

func _setup_result_popup(is_victory: bool, data: Dictionary):
	result_popup.setup_result(is_victory, data)
