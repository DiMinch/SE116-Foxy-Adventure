extends Node

signal coins_changed(new_amount)
signal skill_unlocked(skill_id)
signal weapon_unlocked(weapon_name)

const UPGRADE_SAVE_FILE = "user://upgrades.dat"

var player_coins: int = 0
var unlocked_skills: Dictionary = {}
var unlocked_weapons: Dictionary = {}
var skills_data: Dictionary = {}
var weapon_table: Dictionary = {}
var current_loadout: Array[String] = ["", ""]

func _ready():
	_load_all_weapons()
	_init_skills_data()
	load_upgrades()
	# For Alpha Test
	#generate_full_meta()

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
	player_coins -= skill_data.cost
	unlocked_skills[skill_data.skill_id] = unlocked_skills.get(skill_data.skill_id, 0) + 1
	if skill_data.type == "W" and skill_data.weapon_to_unlock:
		var w = skill_data.weapon_to_unlock
		if skill_data.target_weapon_name == w.weapon_name:
			unlocked_skills[skill_data.target_weapon_name] = unlocked_skills.get(skill_data.target_weapon_name, 0) + 1
		unlocked_weapons[w.weapon_name] = true
		weapon_unlocked.emit(w.weapon_name)
	coins_changed.emit(player_coins)
	skill_unlocked.emit(skill_data.skill_id)
	save_upgrades()

func _set_new_game_defaults():
	player_coins = 20
	unlocked_skills = {}
	unlocked_weapons = {}
	var all_skills = load_all_skill_resources()
	for skill in all_skills:
		if skill.default_unlocked:
			unlocked_skills[skill.skill_id] = skill.max_level
	coins_changed.emit(player_coins)

func save_upgrades():
	var save_data = {
		"coins": player_coins,
		"skills": unlocked_skills,
		"weapons": unlocked_weapons,
		"loadout": current_loadout
	}
	var file = FileAccess.open(UPGRADE_SAVE_FILE, FileAccess.WRITE)
	if file:
		file.store_string(JSON.stringify(save_data))
		file.close()

func load_upgrades():
	if not FileAccess.file_exists(UPGRADE_SAVE_FILE):
		_set_new_game_defaults()
		return
	var file = FileAccess.open(UPGRADE_SAVE_FILE, FileAccess.READ)
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
	if slot_index < 0 or slot_index >= 2: return
	
	current_loadout[slot_index] = weapon_name
	save_upgrades()

func generate_full_meta():
	player_coins = 99999
	# Unlock all skills
	unlocked_skills = {}
	var all_skills = load_all_skill_resources()
	for skill in all_skills:
		unlocked_skills[skill.skill_id] = skill.max_level
	# Unlock all weapons
	unlocked_weapons = {}
	for weapon_name in weapon_table.keys():
		unlocked_weapons[weapon_name] = true
	
	# Loadout default: Blade, Spear
	current_loadout = ["Blade", "Spear"]
	# Update UI
	coins_changed.emit(player_coins)
	for skill in all_skills:
		skill_unlocked.emit(skill.skill_id)
	for wn in unlocked_weapons.keys():
		weapon_unlocked.emit(wn)
	# Save meta
	save_upgrades()
	print("[META] Generated FULL META: all skills & weapons unlocked!")
