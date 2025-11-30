extends HitArea2D
class_name PlayerHitArea2D

@export var stat_damage = 1
@export var basic_damage = 1

@export var current_index_damage = 0
@export var typepassive: bool = false # none = 0, plus = 1
@export var _passivebasic: Array = []
@export var _passiveplus: Array = []

func set_damage_by_basic(passivebasic: Array) -> void:
	_passivebasic = passivebasic
	stat_damage = passivebasic[0]
	current_index_damage = 0

func set_damage_by_plus(passiveplus: Array) -> void:
	_passiveplus = passiveplus
	stat_damage = passiveplus[0]
	current_index_damage = 0

func set_type_passive(isPlus: bool) -> void:
	typepassive = isPlus

func set_stat_damage(stat: float) -> void:
	stat_damage = stat

func update_stat_attack() -> void:
	current_index_damage = get_index_stat_damage(current_index_damage)
	stat_damage = get_stat_damage(current_index_damage)
	set_damage()
	current_index_damage += 1

func get_index_stat_damage(index: int) -> int:
	var size: int = _passivebasic.size()
	if typepassive:
		size = _passiveplus.size()
	
	if index >= size:
		index = 0
	
	return index

func get_stat_damage(index: int) -> float:
	var s_damage: float = 0
	if typepassive:
		s_damage = _passiveplus[index]
	else:
		s_damage = _passivebasic[index]
	
	return s_damage

func set_damage() -> void:
	damage = basic_damage * stat_damage

func set_basic_damage(_basic_damage: float) -> void:
	basic_damage = _basic_damage

func reset_index_damage() -> void:
	current_index_damage = 0
