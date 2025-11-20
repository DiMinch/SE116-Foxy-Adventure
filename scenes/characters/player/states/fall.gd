extends PlayerState

const FALL = "fall"

func _enter() -> void:
	#Change animation to fall
	obj.change_animation(FALL)
	pass

func _update(_delta: float) -> void:
	control_swap_weapon()
	#Control moving
	var is_moving: bool = control_moving()
	#If on floor change to idle if not moving and not jumping
	if obj.is_on_floor() and not is_moving:
		change_state(fsm.states.idle)
	pass
