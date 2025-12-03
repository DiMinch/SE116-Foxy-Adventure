extends Node
class_name Stats

var stats := {} # Dictionary for stats loaded

func load_from_dict(dict_data: Dictionary) -> void:
	stats = dict_data.duplicate(true)

func get_stat(key):
	return stats.get(key, null)

func set_stat(key, value):
	stats[key] = value

func add_stat(key, value):
	stats[key] += value
