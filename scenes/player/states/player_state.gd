class_name PlayerState
extends FSMState

# Input
const RIGHT = "right"
const LEFT = "left"
const JUMP = "jump"
const ATTACK = "attack"
const THROW = "throw"
const SWAP = "swap"
# Skills
const BLOCK = "block"
const DASH = "dash"
const WALL_SLIDE = "wall slide"
const ULTI = "ulti"
const INVULNERABLE  = "invulnerable"

#Control moving and changing state to run
#Return true if moving
func control_moving() -> bool:
	if obj.is_dialogue_active:
		obj.velocity.x = 0
		return false
	var dir: float = Input.get_action_strength(RIGHT) - Input.get_action_strength(LEFT)
	var is_moving: bool = abs(dir) > 0.1
	if obj.is_on_wall() and not obj.is_on_floor():
		if dir != 0.0 and sign(dir) != obj.direction:
			obj.is_push_out_wall = true
			obj.flag_push = true
			obj.turn_around()
	
	if is_moving:
		dir = sign(dir)
		obj.change_direction(int(dir))
		obj.velocity.x = obj.get_movement_speed() * dir
		if obj.is_on_floor():
			change_state(fsm.states.run)
		return true
	else:
		obj.velocity.x = 0
	return false

#Control jumping
#Return true if jumping
func control_jump() -> bool:
	if obj.is_dialogue_active:
		return false
	# Double jump
	if Input.is_action_just_pressed(JUMP) and (obj.current_jumps < obj.max_jumps or (obj.is_on_wall() and obj.can_wall_move)):
		obj.jump()
		obj.current_jumps += 1
		change_state(fsm.states.jump)
		debug_player_skills(JUMP)
		return true
	return false

# Function to control skills
func control_utility_skills() -> bool:
	if obj.is_dialogue_active:
		return false
	if obj.can_dash and Input.is_action_just_pressed(DASH) and obj.is_count_down_dash:
		#change_state(fsm.states.dash) 
		obj.is_count_down_dash = false
		change_state(fsm.states.dash)
		debug_player_skills(DASH)
		return true
	
	if obj.can_block and Input.is_action_pressed(BLOCK) and obj.is_count_down_block:
		#change_state(fsm.states.block)
		obj.is_count_down_block = false
		change_state(fsm.states.block)
		debug_player_skills(BLOCK)
		return true
	return false

func check_wall_movement() -> bool:
	if obj.is_dialogue_active:
		return false
	if obj.can_wall_move and obj.is_on_wall():
		change_state(fsm.states.wall_slide)
		debug_player_skills(WALL_SLIDE)
		return true
	return false

func take_damage(damage) -> void:
	if obj.is_dialogue_active:
		return
	#Player take damage
	obj.take_damage(damage)
	#Player die if health is 0 and change to dead state
	#Player hurt if health is not 0 and change to hurt state
	if obj.health <= 0:
		change_state(fsm.states.dead)
	else:
		change_state(fsm.states.hurt)

func control_attack() -> bool:
	if obj.is_dialogue_active:
		return false
	if Input.is_action_pressed(ATTACK) and !obj.is_attack:
		if obj.has_weapon == true:
			change_state(fsm.states.attack)
		return true
	return false

## Throw Skill of Blade - Unuse
#func control_throw()->bool:
	#if Input.is_action_just_pressed(THROW):
		#obj.Throw()
		##change_state(fsm.states.Throw_blade)
		#return true
	#return false

func control_swap_weapon() -> bool:
	if obj.is_dialogue_active:
		return false
	if Input.is_action_just_pressed(SWAP):
		obj.equip_slot(1 - obj.current_slot_index)
		return true
	return false

func control_ultimate() -> bool:
	if Input.is_action_just_pressed(ULTI) and !obj.is_attack:
		if obj.current_weapon_data and obj.current_ulti_cooldown <= 0: #(and obj.current_weapon_data.current_cooldown <= 0)
			change_state(fsm.states.ulti)
			debug_player_skills("ULTIMATE")
			return true
		elif obj.current_ulti_cooldown > 0:
			print("Ulti is cooling down: ", int(obj.current_ulti_cooldown))
	return false

func control_invulnerable() -> bool:
	print("Did use: INVULNERABLE")
	if Input.is_action_just_pressed(INVULNERABLE) and obj.can_invulnerable:
		debug_player_skills("INVULNERABLE")
		obj.can_invulnerable = false
		return true
	return false

func debug_player_skills(skill_name: String) -> void:
	if skill_name == SWAP:
		print("[SKILL] Player swap weapon to: ", "Thêm debug đổi sang weapon gì?")
	if skill_name == JUMP:
		print("[SKILL] Player Jumped: ", obj.current_jumps)
	if skill_name == "ULTIMATE":
		print("[SKILL] Player used ULTIMATE skill!")
	else:
		print("[SKILL] Player had use: ", skill_name.to_upper())
