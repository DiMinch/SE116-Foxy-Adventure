class_name SwimState
extends PlayerState

func _enter() -> void:
	obj.use_gravity = false
	obj.change_animation("fall")
	obj.animated_sprite.speed_scale = 0.6
	obj.velocity.y -= obj.swim_speed

func _exit() -> void:
	obj.use_gravity = true
	obj.animated_sprite.speed_scale = 1.0
	obj.animated_sprite.position.y = -14
	obj.velocity.y -= obj.get_jump_speed()

func _update(delta: float) -> void:
	var input_dir := Input.get_vector(LEFT, RIGHT, UP, DOWN)
	
	if input_dir.length() > 0.1:
		# Free swim
		obj.velocity = obj.velocity.lerp(input_dir * obj.swim_speed, delta * 5.0)
		
		if input_dir.x != 0:
			obj.change_direction(int(sign(input_dir.x)))
	else:
		# Water friction
		obj.velocity.y += obj.water_gravity * delta
		obj.velocity = obj.velocity.lerp(Vector2.ZERO, delta * obj.water_friction)
	
	# Effect sine wave
	obj.animated_sprite.position.y = -16 + sin(Time.get_ticks_msec() * 0.005) * 2.0
	_update_swim_animation(input_dir)
	
	if not obj.is_in_water:
		if obj.is_on_floor():
			change_state(fsm.states.idle)
		else:
			change_state(fsm.states.jump)
		return
	obj.move_and_slide()

func _update_swim_animation(input_dir: Vector2) -> void:
	if input_dir.y < -0.1:
		obj.change_animation("jump")
	elif input_dir.y > 0.1:
		obj.change_animation("fall")
	elif abs(input_dir.x) > 0.1:
		obj.change_animation("run")
	else:
		obj.change_animation("fall")
