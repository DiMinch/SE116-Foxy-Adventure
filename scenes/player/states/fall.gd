extends PlayerState

const FALL = "fall"
var landed := false
var was_airborne := false

func _enter() -> void:
	obj.change_animation(FALL)
	landed = false
	was_airborne = false
	obj.fall_start_y = obj.global_position.y

func _update(_delta: float) -> void:
	control_invulnerable()
	control_swap_weapon()
	control_jump()
	# Check if in water
	check_swim_transition()
	var is_moving = control_moving()

	# --- Gravity cho rơi tự do ---
	if not obj.is_on_floor():
		obj.velocity.y += obj.gravity * _delta
		was_airborne = true
		var max_fall = 400  # tốc độ rơi tối đa
		if obj.velocity.y > max_fall:
			obj.velocity.y = max_fall

	# --- Wall slide ---
	if not obj.is_on_floor() and obj.is_on_wall() and obj.can_wall_move and (Input.is_action_just_pressed("left") or Input.is_action_just_pressed("right")):
		if obj.velocity.y > obj.wall_slide_speed:
			obj.velocity.y = obj.wall_slide_speed
		# obj.change_animation("wall_slide")

	# --- Push out wall ---
	if obj.is_push_out_wall:
		if obj.flag_push:
			obj.velocity.y = -220
			obj.flag_push = false
		obj.velocity.x += obj.fall_speed * obj.direction

	# --- Reset jumps khi chạm đất ---
	if obj.is_on_floor() and was_airborne and not landed:
		landed = true
		_on_landed()

	if obj.is_on_floor() and not is_moving:
		change_state(fsm.states.idle)

func _on_landed():
	AudioManager.play_sound("landing")
	obj.is_push_out_wall = false
	obj.current_jumps = 0
	
	var fall_distance = obj.global_position.y - obj.fall_start_y
	
	if fall_distance <= obj.FALL_THRESHOLD:
		return
	
	if obj.is_invulnerable or obj.piority_invul:
		return
	
	var damage := int((fall_distance - obj.FALL_THRESHOLD) / 5.0)
	take_damage(damage)
