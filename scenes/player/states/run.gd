extends PlayerState

func _enter() -> void:
	#Change animation to run
	obj.change_animation("run")

func _update(_delta: float) -> void:
	# Check if in water
	check_swim_transition()
	control_invulnerable()
	control_swap_weapon()
	#Control jump
	control_utility_skills()
	control_attack()
	control_ultimate()
	if control_jump():
		return
	#Control moving and if not moving change to idle
	if not control_moving():
		change_state(fsm.states.idle)
	#If not on floor change to fall
	if not obj.is_on_floor():
		change_state(fsm.states.fall)
