extends Door
class_name LevelDoor

@export var level_id: int

@onready var level_label: Label = $LevelLabel
@onready var interactive_area = $InteractiveArea2D

var is_locked: bool = true

func can_open() -> bool:
	return not is_locked

func update_door_status(completed_levels: Dictionary):
	if level_id == 1:
		unlock_door()
	else:
		var previous_level = str(level_id - 1)
		if completed_levels.has(previous_level):
			unlock_door()
		else:
			lock_door()

func unlock_door():
	is_locked = false
	modulate = Color.WHITE
	interactive_area.monitoring = true
	level_label.text = "Level " + str(level_id)
	if level_id == 6 or level_id == 10:
		level_label.add_theme_color_override("font_color", Color.RED)

func lock_door():
	is_locked = true
	modulate = Color(0.2, 0.2, 0.2, 0.8)
	interactive_area.monitoring = false
	level_label.text = "Locked"
