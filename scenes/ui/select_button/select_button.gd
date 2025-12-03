extends Button
class_name SelectButton

@export_file("*.tscn") var scene: String

func _ready() -> void:
	pressed.connect(_on_button_pressed)

func _on_button_pressed() -> void:
	get_tree().change_scene_to_file(scene)
