class_name PlayerState
extends FSMState

const RIGHT = "right"
const LEFT = "left"
const JUMP = "jump"
const ATTACK = "attack"
const THROW = "throw"
const SWAP = "swap"

const BLOCK = "block" 
const DASH = "dash"

#Control moving and changing state to run
#Return true if moving
func control_moving() -> bool:
	var dir: float = Input.get_action_strength(RIGHT) - Input.get_action_strength(LEFT)
	var is_moving: bool = abs(dir) > 0.1
	if obj.is_on_wall() and not obj.is_on_floor():
		if dir != 0.0 and sign(dir) != obj.direction:
			obj.is_push_out_wall = true
			obj.flag_push=true
			obj.turn_around()
	
		
	if is_moving:
		dir = sign(dir)
		obj.change_direction(dir)
		obj.velocity.x = obj.movement_speed * dir
		if obj.is_on_floor():
			change_state(fsm.states.run)
		return true
	else:
		obj.velocity.x = 0
	return false

#Control jumping
#Return true if jumping
func control_jump() -> bool:
	
	#If jump is pressed change to jump state and return true
	#if Input.is_action_just_pressed(JUMP):
		#obj.jump()
		#change_state(fsm.states.jump)
		#return true
	#return false
	
	# Double jump
	if Input.is_action_just_pressed(JUMP) and (obj.current_jumps < obj.max_jumps or (obj.is_on_wall() and obj.can_wall_move)):
		obj.jump()
		obj.current_jumps += 1
		change_state(fsm.states.jump)
		print("Jumped ", obj.current_jumps)
		return true
	return false
	
# Function to control skills
func control_utility_skills() -> bool:
	if obj.can_dash and Input.is_action_just_pressed(DASH) and obj.is_count_downt_dash:
		#change_state(fsm.states.dash) 
		obj.is_count_downt_dash=false
		change_state(fsm.states.dash)
		print("Dashed")
		return true
		
	if obj.can_block and Input.is_action_pressed(BLOCK) and obj.is_count_downt_block:
		#change_state(fsm.states.block)
		obj.is_count_downt_block=false
		change_state(fsm.states.block)
		print("Blocked")
		return true
		 
	return false

func check_wall_movement() -> bool:
	if obj.can_wall_move and obj.is_on_wall():
		change_state(fsm.states.wall_slide)
		print("Wall slide") 
		return true
	return false

func take_damage(damage) -> void:
	#Player take damage
	obj.take_damage(damage)
	
	#Player die if health is 0 and change to dead state
	#Player hurt if health is not 0 and change to hurt state
	if obj.health<=0:
		change_state(fsm.states.dead)
	else :
		change_state(fsm.states.hurt)
	return
	
func control_attack()->bool:
		
	if Input.is_action_pressed(ATTACK):
		if obj.has_weapon==true:
			change_state(fsm.states.attack)
		return true
	return false
func control_throw()->bool:
	if Input.is_action_just_pressed(THROW):
		obj.Throw()
		#change_state(fsm.states.Throw_blade)
		return true
	return false

func control_swap_weapon() -> bool:
	if Input.is_action_just_pressed(SWAP):
		obj.equip_slot(1 - obj.current_slot_index)
		return true
	return false
