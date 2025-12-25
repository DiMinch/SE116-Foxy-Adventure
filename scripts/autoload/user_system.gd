extends Node

const META_SAVE_DIR = "user://profiles/"
const META_FILE_NAME = "meta.dat"
const UPGRADE_FILE_NAME = "upgrades.dat"
const USER_LIST_FILE = "user://users.json"
const LAST_USER_FILE = "user://last_user.dat"

var current_username: String = ""
var meta_data: Dictionary = {
	"levels_completed": {},
	"last_played": 0,
}
var user_list: Dictionary = {}
var player_data: PlayerData = null

func _ready() -> void:
	DirAccess.make_dir_absolute(META_SAVE_DIR)
	_load_user_list()
	_load_last_user()

# Load last user
func _load_last_user():
	if not FileAccess.file_exists(LAST_USER_FILE):
		current_username = ""
		return
	
	var file = FileAccess.open(LAST_USER_FILE, FileAccess.READ)
	if file:
		var last_user = file.get_as_text().strip_edges()
		file.close()
		
		if not last_user.is_empty() and user_list.has(last_user):
			current_username = last_user
			_load_meta_data()
			#Check if time over 4 hours
			var current_time = Time.get_unix_time_from_system()
			var last_played = meta_data.get("last_played", 0)
			if last_played > 0:
				var seconds_elapsed = current_time - last_played
				if seconds_elapsed > 4 * 60 * 60:
					print("[SYSTEM] Your login session has expired (> 4 hours)")
					current_username = ""
					_save_last_user("")
					return
			# If time is accepted
			print("[SYSTEM] Last user found: ", current_username)
			if PlayerData:
				PlayerData.load_upgrades_for_profile(get_current_upgrade_path())

# Save last user
func _save_last_user(username: String):
	var file = FileAccess.open(LAST_USER_FILE, FileAccess.WRITE)
	if file:
		file.store_string(username)
		file.close()

# User management
func _load_user_list():
	if not FileAccess.file_exists(USER_LIST_FILE):
		user_list = {}
		return
	
	var file = FileAccess.open(USER_LIST_FILE, FileAccess.READ)
	if file:
		var json_string = file.get_as_text()
		var data = JSON.parse_string(json_string)
		if data is Dictionary:
			user_list = data
		file.close()
	print("User list loaded. Total users: ", user_list.size())

func _save_user_list():
	var file = FileAccess.open(USER_LIST_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(user_list, "\t"))
		file.close()

# Register
func register_user(username: String, password: String) -> String:
	# Validate input
	if username.length() < 3:
		return "Tên đăng nhập phải có ít nhất 3 ký tự."
	if password.length() < 6:
		return "Mật khẩu phải có ít nhất 6 ký tự."
	if user_list.has(username):
		return "Tên đăng nhập đã tồn tại."
	
	# Save new user
	user_list[username] = password 
	_save_user_list()
	
	# Create save dir for new user
	var user_dir = META_SAVE_DIR + username
	DirAccess.make_dir_absolute(user_dir)
	
	print("[SYSTEM] User registered: ", username)
	return ""

# Login & load data
func login(username: String, password: String) -> String:
	# Check empty
	if username.is_empty() or password.is_empty():
		return "Vui lòng nhập tên đăng nhập và mật khẩu."
	# Check exist user
	if not user_list.has(username):
		return "Tên đăng nhập không tồn tại."
	# Check password
	if user_list[username] != password:
		return "Mật khẩu không chính xác."
	
	current_username = username
	# Save last user
	_save_last_user(current_username)
	# Load & save meta data
	_load_meta_data()
	_save_meta_data()
	# Load player upgrades
	if PlayerData:
		PlayerData.load_upgrades_for_profile(get_current_upgrade_path())
	print("[SYSTEM] User logged in: ", current_username)
	return ""

# Logout
func logout() -> void:
	if current_username.is_empty():
		return
	
	if player_data:
		player_data.save_upgrades()
	
	current_username = ""
	meta_data = { "levels_completed": {}, "last_played": 0 }
	
	_save_last_user("")
	print("[SYSTEM] User logged out.")

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
func record_level_completion(level_id: int, completion_time: float, collected_coins: int) -> bool:
	if current_username.is_empty():
		return false
	
	# Init level data
	if not meta_data.levels_completed.has(str(level_id)):
		meta_data.levels_completed[str(level_id)] = {
			"first_completed": Time.get_unix_time_from_system(),
			"best_completed": completion_time,
			"most_coins": collected_coins
		}
	else:
		var level_data = meta_data.levels_completed.get(str(level_id))
		# Save best time
		if level_data.get("best_completed", INF) > completion_time:
			level_data["best_completed"] = completion_time
		# Update most coins
		if level_data.get("most_coins", 0) < collected_coins:
			level_data["most_coins"] = collected_coins
		meta_data.levels_completed[str(level_id)] = level_data
	_save_meta_data()
	print("[SYSTEM] Level completion recorded for ", level_id)
	return true
