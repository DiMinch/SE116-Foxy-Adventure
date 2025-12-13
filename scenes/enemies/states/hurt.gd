extends EnemyState
var stats_x := -150
var stats_y := -250
func _enter():
	obj.change_animation("hurt")
	obj.velocity.y = stats_y
	obj.velocity.x = stats_x * -sign(obj.velocity.x)
	timer = 0.5

func _update(delta:float):
	var a=obj.health
	var b=obj.max_health
	var target = a*100/b
	obj.hp_bar.set_hp(target)
	if update_timer(delta):
		if obj.health <= 0:
			change_state(fsm.states.dead)
		else:
			change_state(fsm.default_state)
