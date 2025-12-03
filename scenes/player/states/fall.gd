extends PlayerState

const FALL = "fall"

func _enter() -> void:
	#Change animation to fall
	obj.change_animation(FALL)
	pass

func _update(_delta: float) -> void:
	control_swap_weapon()
	control_jump()
	#Control moving
	var is_moving: bool = control_moving()
	#If on floor change to idle if not moving and not jumping
	
	#bám tường
	
	if not obj.is_on_floor() and obj.is_on_wall() and obj.velocity.y > 0.0 and obj.can_wall_move:
		# Giới hạn tốc độ rơi khi bám tường
		if obj.velocity.y > obj.WALL_SLIDE_SPEED:
			obj.velocity.y = obj.WALL_SLIDE_SPEED 
		# Nếu muốn dính sát tường hơn thì có thể giảm vận tốc X
		# obj.velocity.x = 0.0
		# Nếu sau này có anim riêng cho wall slide thì đổi anim ở đây:
		# obj.change_animation("wall_slide")
	if obj.is_push_out_wall == true:
		if obj.flag_push == true:
			obj.velocity.y = -220
			obj.flag_push = false
		obj.velocity.x += obj.speed_push * obj.direction
	
	if obj.is_on_floor():
		obj.is_push_out_wall = false
		obj.current_jumps = 0
	if obj.is_on_floor() and not is_moving:
		change_state(fsm.states.idle)
	pass
