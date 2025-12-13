extends EnemyState

func _enter():
	var a=obj.health
	var b=obj.max_health
	var target = a*100/b
	print("hp_war_lord:", a,"/",b)
	obj.hp_bar.set_hp(target)
	obj.is_being_hurt=true
	obj.change_animation("hurt")
	timer = 1

func _update(delta:float):
	print(obj.health)
	obj.velocity.x=0
	if update_timer(delta):
		if obj.health <= 0:
			#obj.queue_free()
			change_state(fsm.states.dead)
		else:
			change_state(fsm.default_state)
