extends PlayerState

func _enter() -> void:
	#Change animation to jump
	obj.change_animation("jump")

func _update(_delta: float):
	control_swap_weapon()
	#Control moving
	control_moving()
	control_jump()
	#If velocity.y is greater than 0 change to fall
	if obj.velocity.y > 0:
		change_state(fsm.states.fall)
