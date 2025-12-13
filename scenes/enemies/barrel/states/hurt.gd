extends EnemyState

func _enter():
	obj.velocity.x=0
	var a=obj.health
	var b=obj.max_health
	var target = a*100/b
	obj.hp_bar.set_hp(target)
	obj.change_animation("hurt")
	timer = 0.5

func _update(delta:float):
	if update_timer(delta):
		if obj.health <= 0:
			obj.queue_free()
		else:
			change_state(fsm.default_state)
