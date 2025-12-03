extends FSMState
class_name EnemyState

func _update(_delta: float) -> void:
	if is_out_of_range():
		obj.turn_around()

func take_damage(_damage_dir, damage: int) -> void:
	obj.velocity.x = _damage_dir.x * 150
	obj.take_damage(damage)
	change_state(fsm.states.hurt)

func is_out_of_range() -> bool:
	var distance = obj.global_position.x - obj.spawn_position.x
	return abs(distance) > obj.movement_range
