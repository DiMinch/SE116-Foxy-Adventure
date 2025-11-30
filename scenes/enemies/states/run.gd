extends EnemyState
class_name EnemyRunState

func _enter()->void:
	obj.change_animation("run")

func _update(_delta):
	obj.velocity.x = obj.direction * obj.movement_speed
	
	if _should_turn_around():
		obj.turn_around()

func _should_turn_around() -> bool:
	if obj.is_touch_wall():
		return true
	if obj.is_on_floor() and obj.is_can_fall():
		return true
	if _is_out_of_range():
		return true
	return false

func _is_out_of_range() -> bool:
	var distance = obj.global_position.x - obj.spawn_position.x
	return abs(distance) >= obj.movement_range and sign(distance) == obj.direction
