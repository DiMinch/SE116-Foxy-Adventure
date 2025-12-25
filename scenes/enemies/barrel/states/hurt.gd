extends EnemyState

func _enter():
	obj.change_animation("hurt")
	timer = 0.5

func _update(delta:float):
	var a = obj.health
	var b = obj.max_health
	var target = 1.0 * a * 100 / b
	obj.hp_bar.set_hp(target)
	obj.velocity.x = 0
	if update_timer(delta):
		if obj.health <= 0:
			change_state(fsm.states.dead)
		else:
			change_state(fsm.default_state)
