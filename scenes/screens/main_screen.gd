extends Stage

@export_file("*.tscn") var login_screen = "res://scenes/screens/login_screen.tscn"

@onready var level_doors = $World/LevelDoors

var completed_levels = {}

func _ready() -> void:
	if not UserSystem.current_username:
		get_tree().paused = false
		get_tree().change_scene_to_file.call_deferred(login_screen)
		return
	
	completed_levels = UserSystem.meta_data.get("levels_completed", "")
	_update_level_doors()
	_check_skill_tree_unlock()
	super._ready()

func _update_level_doors() -> void:
	for door in level_doors.get_children():
		if door.has_method("update_door_status"):
			door.update_door_status(completed_levels)

func _check_skill_tree_unlock() -> void:
	if completed_levels.has("2"):
		$NPCs.show()
		$World/SignPosts/SkillSignPost.show()
	else:
		$NPCs.hide()
		$World/SignPosts/SkillSignPost.show()
