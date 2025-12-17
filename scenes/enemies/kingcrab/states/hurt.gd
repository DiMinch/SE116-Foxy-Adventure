extends EnemyState

func _enter():
	obj.is_being_hurt=true
	obj.change_animation("hurt")
	timer = 0.5
	
	AudioManager.play_sound("enemy_hurt")

func _update(delta:float):
	var a=obj.health
	var b=obj.max_health
	var target = a*100/b
	obj.hp_bar.set_hp(target)
	obj.velocity.x=0
	if update_timer(delta):
		if obj.health <= 0:
			change_state(fsm.states.dead)
		else:
			change_state(fsm.default_state)
