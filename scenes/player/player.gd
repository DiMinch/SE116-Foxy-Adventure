class_name Player
extends BaseCharacter

#bien xu ly Dash, Block, double_jump, slide on wall, jump on wall
@export var is_count_down_dash = true 
@export var is_count_down_block = true
@export var current_ulti_cooldown: float = 0.0 
@export var WALL_SLIDE_SPEED = 20
@export var speed_push = 150
@export var is_push_out_wall = false
@export var flag_push = false
@export var dash_speed = 50
@export var blade_speed: float = 300

@onready var projectile_factory := $Direction/FireFactory
@onready var onHurt := $Direction/HurtArea2D
@onready var melee_hitbox = $Direction/HitArea2D
@onready var blade_shape = $Direction/HitArea2D/Blade
@onready var spear_shape = $Direction/HitArea2D/Spear
@onready var spear_ulti_shape = $Direction/HitArea2D/SpearUlti
@onready var slash =$Direction/SwordSlash
var fall_multiplier: float = 1.35
var low_jump_multiplier = 0.75
var timer_dash = 10
var ok_tmp_dash = true
var timer_block = 10
var ok_tmp_block = true
var FALL_THRESHOLD = 100

## Player character class that handles movement, combat, and state management
var is_invulnerable: bool = false
var fall_start_y: float = 0.0
var was_on_floor: bool = false
var is_attack: bool = false
var check_attack: bool = true

@export var invulnerable_time := 2.0
@export var has_weapon: bool = false

var weapon_slots: Array[WeaponData] = [null, null]
var weapon_levels: Array[int] = [0, 0]
var current_slot_index: int = 0
var current_weapon_data: WeaponData

## Skill states
var max_jumps: int = 1
var current_jumps: int = 0 
var can_block: bool = false
var can_dash: bool = false
var can_wall_move: bool = false
var can_invulnerable: bool = false
var de_cooldown: float = 1
var time_invul: float = 0
var current_ulti_cooldown_weapon1: float = 0
var current_ulti_cooldown_weapon2: float = 0
var current_time_invul: float = 0
var piority_invul = false

# power up
var decorator_manager: DecoratorManager = null

# dialogue
var is_dialogue_active: bool = false

# === SETUP PLAYER ===
func _ready() -> void:
	add_to_group("player")
	super._ready()
	# Init FSM
	fsm = FSM.new(self, $States, $States/Idle)
	# Init Game Manager
	GameManager.player = self
	# Init Decorator Manager
	decorator_manager = DecoratorManager.new()
	decorator_manager.initialize(self)
	add_child(decorator_manager)
	# Load Checkpoint Data
	if GameManager.has_checkpoint():
		print("Player waiting for checkpoint data...")
	else:
		print("New Game: Loading loadout from PlayerData...")
		load_loadout_from_names(PlayerData.current_loadout)
	# Update Abilities
	update_abilities()
	print("Block: ", can_block)
	print("Dash: ", can_dash)
	print("Wall move: ", can_wall_move)
	
	was_on_floor = is_on_floor()
	if !was_on_floor:
		fall_start_y = global_position.y

func _process(delta: float) -> void:
	if !can_invulnerable && current_time_invul > 0:
		current_time_invul -= delta
		piority_invul = true
	else:
		piority_invul = false

	if current_ulti_cooldown_weapon1 > 0:
		current_ulti_cooldown_weapon1 -= delta
	if current_ulti_cooldown_weapon2 > 0:
		current_ulti_cooldown_weapon2 -= delta
	if current_slot_index:
		current_ulti_cooldown = current_ulti_cooldown_weapon1
	else:
		current_ulti_cooldown = current_ulti_cooldown_weapon2

# INIT STATS
func _init_stats():
	stats.load_from_dict(StatsManager.get_player_stats())
	
	max_health = get_stat("HEALTH")
	movement_speed = get_stat("MOVEMENT_SPEED")
	jump_speed = get_stat("JUMP_SPEED")
	gravity = get_stat("GRAVITY")
	attack_damage = get_stat("ATTACK_DAMAGE")
	attack_speed = get_stat("ATTACK_SPEED")
	health = self.max_health

# SKILL TREE SETUP
func update_abilities() -> void:
	max_jumps = 1
	if PlayerData.has_skill("double_jump"):
		max_jumps = 2
	can_block = PlayerData.has_skill("block")
	can_dash = PlayerData.has_skill("dash")
	can_wall_move = PlayerData.has_skill("wall_movement")
	if PlayerData.has_skill("invulnerable"):
		time_invul = PlayerData.skills_data["invulnerable"].invul_bonus
		can_invulnerable = true
		current_time_invul = time_invul
	if PlayerData.has_skill("cooldown"):
		print(PlayerData.skills_data)
		var skill_data = PlayerData.skills_data["cooldown"]
		de_cooldown = skill_data.de_cooldown

func load_loadout_from_names(weapon_names: Array):
	for i in range(2):
		weapon_slots[i] = null
		if i < weapon_names.size():
			var w_name = weapon_names[i]
			if w_name != "" and PlayerData.weapon_table.has(w_name):
				weapon_slots[i] = PlayerData.weapon_table[w_name]
				weapon_levels[i] = int(PlayerData.unlocked_skills[w_name])
	equip_slot(0)
	var loadout_names = PlayerData.current_loadout

	for i in range(loadout_names.size()):
		var w_name = loadout_names[i]
		
		if w_name != "" and PlayerData.weapon_table.has(w_name):
			var w_data = PlayerData.weapon_table[w_name]

			weapon_slots[i] = w_data
			print("Slot ", i, ": Đã nạp ", w_name)
		else:
			weapon_slots[i] = null

	equip_slot(0)

func equip_slot(index: int):
	if index < 0 or index >= 2: return
	
	current_slot_index = index
	var new_data = weapon_slots[index]
	
	apply_weapon_data(new_data)

func apply_weapon_data(data: WeaponData):
	current_weapon_data = data
	
	melee_hitbox.monitoring = false
	
	if data == null:
		print("Tay không")
		return
	
	if data.skin:
		if data.weapon_name != "None":
			collected_blade()
		else:
			has_weapon = false
		set_sprite_frame(data.skin)
		fsm.change_state(fsm.states.idle)
	
	if data.type_method_attack == "Melee":
		_update_hitbox(current_weapon_data)
		melee_hitbox.reset_index_damage()
		
		if weapon_levels[current_slot_index] > 1:
			melee_hitbox.set_type_passive(true)
		else:
			melee_hitbox.set_type_passive(false)
	
	_configure_hitbox_shape(data.weapon_name)

# === PHYSIC PROCESS ===
func _physics_process(delta: float) -> void:
	# Dash skill
	if is_count_down_dash == false and ok_tmp_dash == true:
		timer_dash = 0
		ok_tmp_dash = false
	
	timer_dash += delta
	if timer_dash >= 10:
		timer_dash = 10
		is_count_down_dash = true
		ok_tmp_dash = true
	# Block skill
	if is_count_down_block == false and ok_tmp_block == true:
		timer_block = 0
		ok_tmp_block = false
	
	timer_block += delta
	if timer_block >= 10:
		timer_block = 10
		is_count_down_block = true
		ok_tmp_block = true
	# Check Logic
	_check_fall_damage()
	if is_on_floor():
		current_jumps = 0
	super._physics_process(delta)

func _check_fall_damage() -> void:
	var on_floor_now := is_on_floor()

	if not on_floor_now and was_on_floor:
		fall_start_y = global_position.y

	if on_floor_now and not was_on_floor:
		if fall_start_y >= 0.0:
			var fall_distance := global_position.y - fall_start_y

			if fall_distance > FALL_THRESHOLD:
				if not is_invulnerable and not piority_invul:

					var f_damage: float = (fall_distance - FALL_THRESHOLD) / 5.0
					print("⚠️ Player mất ", f_damage, 
						  " máu do rơi từ độ cao ", fall_distance)

					fsm.change_state(fsm.states.hurt)
					fsm.current_state.take_damage(f_damage)

		fall_start_y = -1.0

	was_on_floor = on_floor_now


# === COLLISIONS
func _on_hurt_area_2d_hurt(_direction: Variant, _damage: Variant) -> void:
	if is_invulnerable || piority_invul:
		return
	fsm.current_state.take_damage(_damage)

func start_invulnerability():
	is_invulnerable = true
	onHurt.monitoring = false
	
	_blink_effect()
	await get_tree().create_timer(invulnerable_time).timeout
	is_invulnerable = false
	_stop_blink_effect()
	
	await get_tree().process_frame
	onHurt.monitoring = true

func _blink_effect():
	var sprite = _next_animated_sprite
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "modulate:a", 0.3, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	sprite.set_meta("blink_tween", tween)

func _stop_blink_effect():
	var sprite = _next_animated_sprite
	if sprite.has_meta("blink_tween"):
		var tween = sprite.get_meta("blink_tween")
		tween.kill()
		sprite.remove_meta("blink_tween")
		sprite.modulate.a = 1.0

# === WEAPON SKILLS ===
func _configure_hitbox_shape(type: String):
	print(type)
	blade_shape.set_deferred("disabled", true)
	spear_shape.set_deferred("disabled", true)
	
	match type:
		"Blade": blade_shape.set_deferred("disabled", false)
		"Spear": spear_shape.set_deferred("disabled", false)
		"Boomerang": current_weapon_data.attack_behavior.set_boomerang(self)

func can_attack() -> bool:
	if fsm.current_state == fsm.states.run or fsm.current_state == fsm.states.idle :
		return true
	return has_weapon

func collected_blade() -> void:
	has_weapon = true
	#set_animated_sprite($Direction/BladeAnimatedSprite2D)

func Throw()->void:
	var Blade := projectile_factory.create() as RigidBody2D
	Blade.add_collision_exception_with(self)
	var blade_velocity:=Vector2(blade_speed*direction,0.0)
	
	Blade.apply_impulse(blade_velocity)

func load_data_weapon(data: WeaponData) -> void:
	self.attack_damage = data.attack
	self.attack_speed = data.attack_speed

func _on_frame_changed():
	if animated_sprite.animation == "attack":
		var _frame = animated_sprite.frame

		if current_weapon_data:
			if current_weapon_data.attack_behavior && !is_attack:
				is_attack = true
				current_weapon_data.attack_behavior.execute_action(self, current_weapon_data)
			else:
				melee_hitbox.set_deferred("monitoring", false)
		else:
			melee_hitbox.set_deferred("monitoring", false)
	else:
		is_attack = false
		melee_hitbox.set_deferred("monitoring", false)

func _update_hitbox(data_weapon: MeleeData) -> void:
	melee_hitbox.set_basic_damage(data_weapon.attack)
	melee_hitbox.set_damage_by_basic(data_weapon.passivebasic)
	melee_hitbox.set_damage_by_plus(data_weapon.passiveplus)
	melee_hitbox.set_damage()

# === STATE MANAGER ===
func save_state() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y]
	}

func load_state(data: Dictionary) -> void:
	"""Load player state from checkpoint data"""
	if data.has("position"):
		var pos_array = data["position"]
		global_position = Vector2(pos_array[0], pos_array[1])

# === POWER UP ===
func get_movement_speed() -> float:
	if decorator_manager != null:
		return decorator_manager.get_effective_movement_speed()
	return movement_speed

func get_jump_speed() -> float:
	if decorator_manager != null:
		return decorator_manager.get_effective_jump_speed()
	return jump_speed

func restore_health(amount: int) -> void:
	self.health = min(self.health + amount, max_health)
	print("Current HP: ", health, "/", max_health)

func collect_powerup(powerup_id: String) -> void:
	decorator_manager.apply_powerup(powerup_id)
