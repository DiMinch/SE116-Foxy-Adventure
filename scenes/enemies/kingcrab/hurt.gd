extends EnemyState

func _enter():
	obj.is_being_hurt=true
	obj.change_animation("hurt")
	timer = 0.5

func _update(delta:float):
	obj.velocity.x=0
	if update_timer(delta):
		if obj.health <= 0:
			obj.queue_free()
		else:
			change_state(fsm.default_state)
