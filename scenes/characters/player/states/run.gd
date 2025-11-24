extends PlayerState

func _enter() -> void:
	#Change animation to run
	obj.change_animation("run")
	pass

func _update(_delta: float):
	control_swap_weapon()
	#Control jump
	control_utility_skills()
	control_attack()
	if control_jump():
		return
	#Control moving and if not moving change to idle
	if not control_moving():
		change_state(fsm.states.idle)
	#If not on floor change to fall
	if not obj.is_on_floor():
		change_state(fsm.states.fall)
	pass
