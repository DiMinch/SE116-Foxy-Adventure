extends Node

var player_stats := {}
var enemy_stats := {}
var PLAYER_STATS = "res://data/stats/player_stats.json"
var ENEMY_STATS = "res://data/stats/enemy_stats"

func _ready() -> void:
	load_player_stats()
	load_enemy_stats()

func load_json(path: String) -> Dictionary:
	var file := FileAccess.open(path, FileAccess.READ)
	if file:
		var text = file.get_as_text()
		return JSON.parse_string(text)
	return {}

func load_player_stats():
	player_stats = load_json(PLAYER_STATS)

func load_enemy_stats():
	var dir := DirAccess.open(ENEMY_STATS)
	if dir:
		for file in dir.get_files():
			if file.ends_with(".json"):
				var enemy_name = file.trim_suffix(".json")
				enemy_stats[enemy_name] = load_json(ENEMY_STATS + "/" + file)

func get_player_stats() -> Dictionary:
	print("Player Stats: ", player_stats)
	return player_stats.duplicate(true)

func get_enemy_stats(enemy_type: String) -> Dictionary:
	return enemy_stats.get(enemy_type, {}).duplicate(true)
