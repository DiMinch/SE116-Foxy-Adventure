extends Node

const META_SAVE_DIR = "user://profiles/"
const META_FILE_NAME = "meta.dat"
const UPGRADE_FILE_NAME = "upgrades.dat"

var current_username: String = ""
var meta_data: Dictionary = {
	"levels_completed": {},
	"last_played": 0,
}

var player_data: PlayerData = null

func _ready() -> void:
	DirAccess.make_dir_absolute(META_SAVE_DIR)

# Login & load data
func login(username: String) -> bool:
	if username.is_empty():
		return false
	
	current_username = username
	# Load meta data
	_load_meta_data()
	# Load player upgrades
	if player_data:
		player_data.load_upgrades_for_profile(get_current_upgrade_path())
	print("User logged in: ", current_username)
	return true

# Get file upgrades path
func get_current_upgrade_path() -> String:
	return META_SAVE_DIR + current_username + "/" + UPGRADE_FILE_NAME

# Get file meta path
func get_current_meta_path() -> String:
	return META_SAVE_DIR + current_username + "/" + META_FILE_NAME

# Load meta data
func _load_meta_data():
	var file_path = get_current_meta_path()
	if not FileAccess.file_exists(file_path):
		meta_data = {
			"levels_completed": {},
			"last_played": Time.get_unix_time_from_system()
		}
		return
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var data = JSON.parse_string(json_string)
		if data is Dictionary:
			meta_data = data
		file.close()

# Save meta data
func _save_meta_data():
	if current_username.is_empty():
		push_error("Cannot save meta data: No user logged in.")
		return
	
	var user_dir = META_SAVE_DIR + current_username
	DirAccess.make_dir_absolute(user_dir)
	
	var file = FileAccess.open(get_current_meta_path(), FileAccess.WRITE)
	if file:
		meta_data.last_played = Time.get_unix_time_from_system()
		file.store_string(JSON.stringify(meta_data, "\t"))
		file.close()

# Update when passed level
func record_level_completion(level_id: String, completion_time: float) -> bool:
	if current_username.is_empty():
		return false
	
	var level_data = meta_data.levels_completed.get(level_id, {})
	# Save best time
	if level_data.get("time", INF) > completion_time:
		level_data["time"] = completion_time
	
	# Save first complete time (if not have)
	if not level_data.has("first_completion_time"):
		level_data["first_completion_time"] = Time.get_unix_time_from_system()
		
	meta_data.levels_completed[level_id] = level_data
	_save_meta_data()
	print("Level completion recorded for ", level_id)
	return true
