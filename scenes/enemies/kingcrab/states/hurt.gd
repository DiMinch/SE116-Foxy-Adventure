extends EnemyState

func _enter():
	var a=obj.health
	var b=obj.max_health
	var target = a*100/b
	print("king_crab:",a,"/",b)
	obj.hp_bar.set_hp(target)
	obj.is_being_hurt=true
	obj.change_animation("hurt")
	timer = 0.5

func _update(delta:float):
	obj.velocity.x=0
	if update_timer(delta):
		if obj.health <= 0:
			change_state(fsm.states.dead)
		else:
			change_state(fsm.default_state)
