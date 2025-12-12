extends PlayerState

const FALL = "fall"

func _enter() -> void:
	obj.change_animation(FALL)

func _update(_delta: float) -> void:
	control_invulnerable()
	control_swap_weapon()
	control_jump()
	
	var is_moving = control_moving()

	# --- Gravity cho rơi tự do ---
	if not obj.is_on_floor():
		obj.velocity.y += obj.gravity * _delta
		var max_fall = 400  # tốc độ rơi tối đa
		if obj.velocity.y > max_fall:
			obj.velocity.y = max_fall

	# --- Wall slide ---
	if not obj.is_on_floor() and obj.is_on_wall() and obj.can_wall_move:
		if obj.velocity.y > obj.WALL_SLIDE_SPEED:
			obj.velocity.y = obj.WALL_SLIDE_SPEED
		# obj.change_animation("wall_slide")

	# --- Push out wall ---
	if obj.is_push_out_wall:
		if obj.flag_push:
			obj.velocity.y = -220
			obj.flag_push = false
		obj.velocity.x += obj.speed_push * obj.direction

	# --- Reset jumps khi chạm đất ---
	if obj.is_on_floor():
		obj.is_push_out_wall = false
		obj.current_jumps = 0

	if obj.is_on_floor() and not is_moving:
		change_state(fsm.states.idle)
