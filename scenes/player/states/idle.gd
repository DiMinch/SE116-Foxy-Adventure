extends PlayerState

## Idle state for player character
func _enter() -> void:
	obj.change_animation("idle")

func _update(_delta: float) -> void:
	control_swap_weapon()
	# Control jump
	control_jump()
	# Control moving
	control_moving()
	# If not on floor change to fall
	control_attack()
	## Control throw blade: UNUSE
	#control_throw()
	control_utility_skills()
	if not obj.is_on_floor():
		change_state(fsm.states.fall)
