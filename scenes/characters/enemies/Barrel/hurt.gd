extends EnemyState
func _enter():
	obj.change_animation("hurt")
	obj.velocity.x=0
	timer =0.2
func _update(delta:float):
	if update_timer(delta):
		if obj.health <=0:
			obj.queue_free()
		else :
			change_state(fsm.default_state)
