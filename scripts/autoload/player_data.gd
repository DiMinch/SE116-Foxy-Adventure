extends Node

signal coins_changed(new_amount)
signal skill_unlocked(skill_id)
signal weapon_unlocked(weapon_name)
signal loadout_updated

var current_upgrade_save_path: String = ""

var player_coins: int = 0
var unlocked_skills: Dictionary = {}
var unlocked_weapons: Dictionary = {}
var skills_data: Dictionary = {}
var weapon_table: Dictionary = {}
var current_loadout: Array[String] = ["", ""]
var is_second_slot_unlocked: bool = false

func _ready():
	UserSystem._load_last_user()
	_load_all_weapons()
	_init_skills_data()

func _init_skills_data():
	var all_skills_resources = load_all_skill_resources()
	for skill_res in all_skills_resources:
		if skill_res is SkillData:
			skills_data[skill_res.skill_id] = skill_res
	
	print("Đã cache ", skills_data.size(), " kỹ năng vào bộ nhớ.")

func _load_all_weapons():
	var dir = DirAccess.open("res://data/weapons")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if dir.current_is_dir() == false and file_name.get_extension() == "tres" or file_name.get_extension() == "remap":
				file_name = file_name.get_basename()
				if file_name.get_extension() != "tres":
					file_name += ".tres"
				var weapon: WeaponData = load("res://data/weapons/%s" % file_name)
				if weapon:
					weapon_table[weapon.weapon_name] = weapon
			file_name = dir.get_next()
		dir.list_dir_end()

func has_skill(skill_id: StringName) -> bool:
	return unlocked_skills.get(skill_id, 0) > 0

func can_upgrade(skill_data: SkillData) -> bool:
	if not skill_data:
		return false
	if unlocked_skills.get(skill_data.skill_id, 0) >= skill_data.max_level:
		return false
	for pre_id in skill_data.prerequisites:
		if not has_skill(pre_id):
			return false
	return player_coins >= skill_data.cost

func upgrade_skill(skill_data: SkillData):
	if not can_upgrade(skill_data):
		return
	# Minus coins
	player_coins -= skill_data.cost
	# Upgrade skill level
	var new_skill_level = unlocked_skills.get(skill_data.skill_id, 0) + 1
	unlocked_skills[skill_data.skill_id] = new_skill_level
	
	# Handle Logic for Second slot
	if skill_data.skill_id == "second_slot":
		is_second_slot_unlocked = true
	
	# Handle other W skill
	if skill_data.type == "W" and skill_data.weapons_to_unlock:
		for weapon in skill_data.weapons_to_unlock:
			var w_name = weapon.weapon_name
			unlocked_weapons[w_name] = true
			unlocked_skills[w_name] = unlocked_skills.get(w_name, 0) + 1
			weapon_unlocked.emit(weapon.weapon_name)
	
	coins_changed.emit(player_coins)
	skill_unlocked.emit(skill_data.skill_id)
	save_upgrades()

func _set_new_game_defaults():
	player_coins = 0
	unlocked_skills = {}
	unlocked_weapons = {}
	is_second_slot_unlocked = false
	
	# Unlock default skill - NOT USE
	#var all_skills = load_all_skill_resources()
	#for skill in all_skills:
		#if skill.default_unlocked:
			#unlocked_skills[skill.skill_id] = skill.max_level
	coins_changed.emit(player_coins)
	save_upgrades()

func save_upgrades():
	if current_upgrade_save_path.is_empty():
		var path_from_user_system = UserSystem.get_current_upgrade_path()
		if not path_from_user_system.is_empty():
			current_upgrade_save_path = path_from_user_system
		else:
			push_error("Cannot save ugrades: UserSystem reports an empty save path.")
			return
	
	var save_data = {
		"coins": player_coins,
		"skills": unlocked_skills,
		"weapons": unlocked_weapons,
		"loadout": current_loadout,
		"loadout_index": is_second_slot_unlocked
	}
	var file = FileAccess.open(current_upgrade_save_path, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data, "\t"))
		file.close()

func load_upgrades_for_profile(path: String):
	current_upgrade_save_path = path
	
	if not FileAccess.file_exists(current_upgrade_save_path):
		_set_new_game_defaults()
		return
	
	var file = FileAccess.open(current_upgrade_save_path, FileAccess.READ)
	if not file:
		_set_new_game_defaults()
		return
	
	var json_string = file.get_as_text().strip_edges()
	file.close()
	if json_string == "":
		_set_new_game_defaults()
		return
	
	var data = JSON.parse_string(json_string)
	if data == null:
		_set_new_game_defaults()
		return
	
	player_coins = data.get("coins", 0)
	unlocked_skills = data.get("skills", {})
	unlocked_weapons = data.get("weapons", {})
	is_second_slot_unlocked = data.get("loadout_index", false)
	var raw_loadout = data.get("loadout", ["", ""])
	current_loadout.assign(raw_loadout)
	
	var converted = {}
	for wname in unlocked_weapons.keys():
		if weapon_table.has(wname):
			converted[wname] = true
	unlocked_weapons = converted
	coins_changed.emit(player_coins)

func load_all_skill_resources() -> Array:
	var skills = []
	var dir = DirAccess.open("res://data/skills")
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		while file_name != "":
			if file_name.ends_with(".tres"):
				var skill: SkillData = load("res://data/skills/%s" % file_name)
				if skill:
					skills.append(skill)
			file_name = dir.get_next()
		dir.list_dir_end()
	return skills

func set_loadout_slot(slot_index: int, weapon_name: String):
	if slot_index < 0 or slot_index >= 2:
		return
	if slot_index == 1 and not is_second_slot_unlocked:
		print("Slot 2 chưa mở khóa")
		return
	
	current_loadout[slot_index] = weapon_name
	save_upgrades()
	# Update player loadout
	loadout_updated.emit()
