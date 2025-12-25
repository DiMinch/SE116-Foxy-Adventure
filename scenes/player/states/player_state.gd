class_name PlayerState
extends FSMState

### INPUT CONSTANTS ###
const RIGHT = "right"
const LEFT = "left"
const UP = "up"
const DOWN = "down"
const JUMP = "jump"
const ATTACK = "attack"
const SWAP = "swap"
const BLOCK = "block"
const DASH = "dash"
const WALL_SLIDE = "wall slide"
const ULTI = "ulti"
const INVULNERABLE = "invulnerable"

### MOVEMENT LOGIC ###
#Control moving and changing state to run
#Return true if moving
func control_moving() -> bool:
	if _is_locked(): return false
	
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
	
	obj.velocity.x = 0
	return false

#Control jumping
#Return true if jumping
func control_jump() -> bool:
	if _is_locked(): return false
	
	var can_normal_jump = obj.current_jumps < obj.max_jumps
	var can_wall_jump = obj.is_on_wall() and obj.can_wall_move
	
	# Double jump
	if Input.is_action_just_pressed(JUMP) and (can_normal_jump or can_wall_jump):
		obj.jump()
		obj.current_jumps += 1
		change_state(fsm.states.jump)
		return true
	return false

func check_wall_movement() -> bool:
	if _is_locked(): return false
	
	if obj.can_wall_move and obj.is_on_wall() and not obj.is_on_floor():
		change_state(fsm.states.wall_slide)
		return true
	return false

func check_swim_transition() -> bool:
	if obj.is_in_water:
		change_state(fsm.states.swim)
		return true
	return false

### ULTILITY SKILLS ###
# Function to control skills
func control_utility_skills() -> bool:
	if _is_locked(): return false
	
	# Dash
	if obj.can_dash and Input.is_action_just_pressed(DASH) and obj.is_cooldown_dash:
		obj.is_cooldown_dash = false
		obj.ok_tmp_dash = true
		change_state(fsm.states.dash)
		_log_skill(DASH)
		return true
	
	# Block
	if obj.can_block and Input.is_action_pressed(BLOCK) and obj.is_cooldown_block:
		obj.is_cooldown_block = false
		obj.ok_tmp_block = true
		change_state(fsm.states.block)
		_log_skill(BLOCK)
		return true
	
	return false

func control_invulnerable() -> bool:
	#print("Did use: INVULNERABLE")
	if Input.is_action_just_pressed(INVULNERABLE) and obj.can_invulnerable:
		_log_skill("INVULNERABLE")
		obj.can_invulnerable = false
		return true
	return false

### COMBAT LOGIC ###
func control_attack() -> bool:
	if _is_locked() or obj.is_invulnerable:
		return false
	if Input.is_action_pressed(ATTACK) and !obj.is_attack:
		if obj.can_attack():
			change_state(fsm.states.attack)
			return true
	return false

func control_swap_weapon() -> bool:
	if _is_locked(): return false
	
	if Input.is_action_just_pressed(SWAP):
		if obj.current_slot_index == 0 and not PlayerData.is_second_slot_unlocked:
			return false
		
		obj.equip_slot(1 - obj.current_slot_index)
		_log_skill(SWAP)
		return true
	return false

func control_ultimate() -> bool:
	if _is_locked() or !obj.is_invulnerable:
		return false
	
	if Input.is_action_just_pressed(ULTI) and !obj.is_attack:
		if obj.current_weapon_data and obj.current_ulti_cooldown <= 0:
			change_state(fsm.states.ulti)
			_log_skill(ULTI)
			return true
		elif obj.current_ulti_cooldown > 0:
			print("Ulti is cooling down: ", int(obj.current_ulti_cooldown))
			pass
	return false

func take_damage(damage) -> void:
	obj.take_damage(damage)
	
	if obj.health <= 0:
		change_state(fsm.states.dead)
	else:
		change_state(fsm.states.hurt)

### HELPERS ###
# Check if Player is locked by dialogue
func _is_locked() -> bool:
	return obj.is_dialogue_active

# DEBUG
func _log_skill(skill_name: String) -> void:
	var msg := "[SKILL] Player "
	match  skill_name:
		SWAP: msg += "swapped weapon to " + obj.current_weapon_data.weapon_name
		ULTI: msg += "used ULTIMATE SKILL"
		_: msg += "used: " + skill_name.to_upper()
	print(msg)
