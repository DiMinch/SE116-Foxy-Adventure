extends EnemyState

var time_prepare: float = 0.3

func _enter()->void:
	obj.change_animation("attack")
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = false
	timer = 1.2
	time_prepare = 0.3
	obj.velocity.x = 0
	
	AudioManager.play_sound("starfish_spin")

func _exit()->void:
	obj.get_node("Direction/HitArea2D/CollisionShape2D").disabled = true
	
func _update(delta: float)->void:
	time_prepare -= delta
	if time_prepare < 0:
		obj.velocity.x = obj.direction * obj.attack_speed
		if _should_turn_around():
			obj.turn_around()
			change_state(fsm.states.run)
	if update_timer(delta):
		change_state(fsm.previous_state)
	

func _should_turn_around()->bool:
	if obj.is_touch_wall():
		return true
	if obj.is_on_floor() and obj.is_can_fall():
		return true
	return false
