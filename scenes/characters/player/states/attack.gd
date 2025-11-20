extends PlayerState

func _enter()->void:
	obj.change_animation(ATTACK)
	timer = 0.2
	obj.velocity.x=0
	timer = 0.3

func _exit() -> void:
	obj.is_attack = false
	if obj.melee_hitbox:
		obj.melee_hitbox.set_deferred("monitoring", false)

func _update(delta:float)->void:
	if update_timer(delta):
		change_state(fsm.previous_state)
