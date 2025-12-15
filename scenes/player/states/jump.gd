extends PlayerState

var rise_slow_timer := 0.0
@export var rise_slow_duration := 0.12
@export var rise_slow_factor := 0.96

func _enter() -> void:
	#Change animation to jump
	obj.change_animation("jump")
	AudioManager.play_sound("player_jump")
	rise_slow_timer = rise_slow_duration

func _update(_delta: float):
	control_invulnerable()
	control_swap_weapon()
	#Control moving
	control_moving()
	control_jump()
	
	if obj.velocity.y < 0:
		if rise_slow_timer > 0:
			obj.velocity.y *= rise_slow_factor
			rise_slow_timer -= _delta
		elif not Input.is_action_pressed("jump"):
			obj.velocity.y *= obj.low_jump_multiplier
	else:
		obj.velocity.y += obj.gravity * obj.fall_multiplier * _delta
	#If velocity.y is greater than 0 change to fall
	if obj.velocity.y > 0:
		change_state(fsm.states.fall)
