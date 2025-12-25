class_name Player
extends BaseCharacter

### REGIONS: CONSTANTS & ENUMS ###
const DASH_COOLDOWN = 10
const BLOCK_COOLDOWN = 10
const FALL_THRESHOLD = 200

### REGIONS: EXPORTS (Inspector) ###
@export_group("Ultility Skills Settings")
@export var wall_slide_speed := 20.0
@export var dash_speed = 50
@export var fall_speed = 150
@export var invulnerable_time := 1.0
@export_group("Weapons Skills Settings")
@export var blade_speed: float = 300
@export var has_weapon: bool = false
@export_group("Swim Settings")
@export var swim_speed := 180.0
@export var water_friction := 2.0
@export var water_gravity := 20

### REGIONS: ONREADY NODES ###
@onready var onHurt := $Direction/HurtArea2D
@onready var projectile_factory := $Direction/FireFactory
@onready var melee_hitbox = $Direction/HitArea2D
@onready var blade_shape = $Direction/HitArea2D/Blade
@onready var spear_shape = $Direction/HitArea2D/Spear
@onready var spear_ulti_shape = $Direction/HitArea2D/SpearUlti
@onready var slash = $Direction/SwordSlash
# Swim
@onready var water_area := $Direction/WaterArea2D
# Sound
@onready var audio_player := $AudioStreamPlayer

### REGIONS: VARIABLES ###
# Gameplay Flags
var is_attack: bool = false
var is_ulti: bool = false
var check_attack: bool = true
# Jump State & Double Jump skills
var fall_multiplier: float = 1.35
var low_jump_multiplier: float = 0.75
var current_jumps: int = 0
# Fall State
var is_push_out_wall := false
var flag_push := false
var fall_start_y: float = 0.0
# Dash skills
var timer_dash := 10.0
var is_cooldown_dash := true
var ok_tmp_dash = true
# Block skills
var timer_block := 10.0
var is_cooldown_block = true
var ok_tmp_block = true
# Combat & Weapons
var current_slot_index: int = 0
var current_weapon_data: WeaponData
var weapon_slots: Array[WeaponData] = [null, null]
var weapon_levels: Array[int] = [0, 0]
# Invulnerable Skill
var invulnerable_lock_count := 0
var is_invulnerable: bool = false
var piority_invul = false
# Ultimate Skills
var current_ulti_cooldown: float = 0.0
var current_ulti_cooldown_weapon_1: float = 0
var current_ulti_cooldown_weapon_2: float = 0
var de_cooldown: float = 1.0
# Ultility Skills
var max_jumps: int = 1
var can_block: bool = false
var can_dash: bool = false
var can_wall_move: bool = false
var can_invulnerable: bool = false
var time_invul: float = 0.0
var current_time_invul: float = 0
# Swimming State
var is_in_water := false
# Powerup
var decorator_manager: DecoratorManager = null
# Dialogue
var is_dialogue_active: bool = false

### REGION: INITIALIZATION ###
func _ready() -> void:
	add_to_group("player")
	super._ready()
	_initialize_system()
	_load_initial_data()
	update_abilities()
	# Connect and equip
	PlayerData.loadout_updated.connect(_on_player_data_loadout_changed)

func _init_stats():
	stats.load_from_dict(StatsManager.get_player_stats())
	
	max_health = get_stat("HEALTH")
	movement_speed = get_stat("MOVEMENT_SPEED")
	jump_speed = get_stat("JUMP_SPEED")
	gravity = get_stat("GRAVITY")
	attack_damage = get_stat("ATTACK_DAMAGE")
	attack_speed = get_stat("ATTACK_SPEED")
	health = self.max_health
	melee_hitbox.damage = attack_damage
	
	health_changed.emit(health, max_health)

func _initialize_system() -> void:
	fsm = FSM.new(self, $States, $States/Idle)
	GameManager.player = self
	
	decorator_manager = DecoratorManager.new()
	decorator_manager.initialize(self)
	add_child(decorator_manager)

func _load_initial_data() -> void:
	if GameManager.has_checkpoint():
		print("Player waiting for checkpoint data...")
	else:
		print("New Game: Loading loadout from PlayerData...")
		load_loadout_from_names(PlayerData.current_loadout)

### REGION: CORE LOOP ###
func _process(delta: float) -> void:
	_handle_invulnerablility_timer(delta)
	_handle_ultimate_cooldowns(delta)

func _physics_process(delta: float) -> void:
	_update_cooldown_timers(delta)
	# Check Logic
	if is_on_floor():
		current_jumps = 0
	
	super._physics_process(delta)
	_handle_walking_audio()

### REGION: MOVEMENT & PHYSICS LOGIC ###
func _update_cooldown_timers(delta: float) -> void:
	# Dash cooldown
	if ok_tmp_dash:
		timer_dash = 0.0
		ok_tmp_dash = false
	if not is_cooldown_dash:
		timer_dash = min(timer_dash + delta, DASH_COOLDOWN)
		if timer_dash >= DASH_COOLDOWN:
			is_cooldown_dash = true
	
	# Block cooldown
	if ok_tmp_block:
		timer_block = 0.0
		ok_tmp_block = false
	if not is_cooldown_block:
		timer_block = min(timer_block + delta, BLOCK_COOLDOWN)
		if timer_block >= BLOCK_COOLDOWN:
			is_cooldown_block = true

func _handle_walking_audio() -> void:
	if fsm.current_state == fsm.states.run:
		if not audio_player.playing:
			audio_player.play()
	else:
		audio_player.stop()

### REGION: COMBAT & SKILLS ###
func update_abilities() -> void:
	# Double jumps
	max_jumps = 2 if PlayerData.has_skill("double_jump") else 1
	# Block
	can_block = PlayerData.has_skill("block")
	# Dash
	can_dash = PlayerData.has_skill("dash")
	# Wall movement
	can_wall_move = PlayerData.has_skill("wall_movement")
	# Invulnerability
	if PlayerData.has_skill("invulnerable"):
		time_invul = PlayerData.skills_data["invulnerable"].invul_bonus
		can_invulnerable = true
		current_time_invul = time_invul
	# Ultimate Cooldown
	if PlayerData.has_skill("cooldown"):
		print(PlayerData.skills_data)
		var skill_data = PlayerData.skills_data["cooldown"]
		de_cooldown = skill_data.de_cooldown

func _handle_invulnerablility_timer(delta: float) -> void:
	if !can_invulnerable && current_time_invul > 0:
		current_time_invul -= delta
		piority_invul = true
	else:
		piority_invul = false

func _handle_ultimate_cooldowns(delta: float) -> void:
	if current_ulti_cooldown_weapon_1 > 0:
		current_ulti_cooldown_weapon_1 -= delta
	if current_ulti_cooldown_weapon_2 > 0:
		current_ulti_cooldown_weapon_2 -= delta
	
	if current_slot_index == 0:
		current_ulti_cooldown = current_ulti_cooldown_weapon_1
	else:
		current_ulti_cooldown = current_ulti_cooldown_weapon_2

### REGION: WEAPON MANAGEMENT ###
func load_loadout_from_names(weapon_names: Array) -> void:
	for i in range(2):
		weapon_slots[i] = null
		if i < weapon_names.size():
			var w_name = weapon_names[i]
			if w_name != "" and PlayerData.weapon_table.has(w_name):
				weapon_slots[i] = PlayerData.weapon_table[w_name]
				weapon_levels[i] = int(PlayerData.unlocked_skills[w_name])
	equip_slot(0)

func equip_slot(index: int) -> void:
	# Check valid slot
	if index < 0 or index >= 2: return
	# Check second slot unlocked
	if index == 1 and not PlayerData.is_second_slot_unlocked: return
	# Check slot has data
	if weapon_slots[index] == null and index != 0: return
	
	current_slot_index = index
	var new_data = weapon_slots[index]
	apply_weapon_data(new_data)

func apply_weapon_data(data: WeaponData) -> void:
	current_weapon_data = data
	melee_hitbox.monitoring = false
	
	if data == null:
		has_weapon = false
		return
	
	has_weapon = (data.weapon_name != "None")
	if data.skin:
		set_sprite_frame(data.skin)
		fsm.change_state(fsm.states.idle)
	
	if data.type_method_attack == "Melee":
		_update_hitbox(current_weapon_data)
		melee_hitbox.reset_index_damage()
		melee_hitbox.set_type_passive(weapon_levels[current_slot_index] > 1)
	
	_configure_hitbox_shape(data.weapon_name)

func _update_hitbox(data_weapon: MeleeData) -> void:
	melee_hitbox.set_basic_damage(data_weapon.attack)
	melee_hitbox.set_damage_by_basic(data_weapon.passivebasic)
	melee_hitbox.set_damage_by_plus(data_weapon.passiveplus)
	melee_hitbox.set_damage()

func _configure_hitbox_shape(type: String) -> void:
	blade_shape.set_deferred("disabled", true)
	spear_shape.set_deferred("disabled", true)
	
	match type:
		"Blade": blade_shape.set_deferred("disabled", false)
		"Spear": spear_shape.set_deferred("disabled", false)
		"Boomerang": current_weapon_data.attack_behavior.set_boomerang(self)

### REGION: COLLISIONS ###
func _on_hurt_area_2d_hurt(_direction: Variant, _damage: Variant) -> void:
	if is_invulnerable or piority_invul:
		return
	fsm.current_state.take_damage(_damage)

func _on_water_area_2d_area_entered(area: Area2D) -> void:
	if area.is_in_group("water"):
		is_in_water = true
		print("Is in water")

func _on_water_area_2d_area_exited(area: Area2D) -> void:
	if area.is_in_group("water"):
		is_in_water = false

func start_invulnerability() -> void:
	if is_invulnerable:
		return
	acquire_invulnerable_lock()
	onHurt.monitoring = false
	_blink_effect()
	await get_tree().create_timer(invulnerable_time).timeout
	
	release_invulnerable_lock()
	_stop_blink_effect()
	await get_tree().process_frame
	onHurt.monitoring = true

func acquire_invulnerable_lock():
	invulnerable_lock_count += 1
	is_invulnerable = true

func release_invulnerable_lock():
	invulnerable_lock_count = max(invulnerable_lock_count - 1, 0)
	if invulnerable_lock_count == 0:
		is_invulnerable = false

func _blink_effect():
	var sprite = _next_animated_sprite

	if sprite.has_meta("blink_tween"):
		sprite.get_meta("blink_tween").kill()

	var tween = create_tween().set_loops()
	tween.tween_property(sprite, "modulate:a", 0.3, 0.1)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	sprite.set_meta("blink_tween", tween)

func _stop_blink_effect():
	var sprite = _next_animated_sprite
	if sprite.has_meta("blink_tween"):
		sprite.get_meta("blink_tween").kill()
		sprite.remove_meta("blink_tween")
	sprite.modulate.a = 1.0

### REGION: GETTERS & HELPERS ###
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
	health_changed.emit(self.health, max_health)

func collect_powerup(powerup_id: String) -> void:
	decorator_manager.apply_powerup(powerup_id)

func can_attack() -> bool:
	# Check if decorator manager has attack
	if decorator_manager != null and decorator_manager.can_blade_attack():
		return true
	# Check if player state is run or idle
	if fsm.current_state == fsm.states.run or fsm.current_state == fsm.states.idle:
		return has_weapon
	return has_weapon

### REGION: SIGNAL CALLBACK ###
func _on_player_data_loadout_changed() -> void:
	load_loadout_from_names(PlayerData.current_loadout)

func _on_frame_changed() -> void:
	if animated_sprite.animation == "attack":
		_handle_attack_frame_logic()
	else:
		is_attack = false
		melee_hitbox.set_deferred("monitoring", false)

func _handle_attack_frame_logic() -> void:
	if decorator_manager.can_blade_attack():
		is_attack = true
		melee_hitbox.set_deferred("monitoring", true)
		blade_shape.set_deferred("disabled", false)
		return
	
	if current_weapon_data and current_weapon_data.attack_behavior and not is_attack and not is_ulti:
		is_attack = true
		current_weapon_data.attack_behavior.execute_action(self, current_weapon_data)
	else:
		melee_hitbox.set_deferred("monitoring", false)

### REGION: SAVE STATE ###
func save_state() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y]
	}

func load_state(data: Dictionary) -> void:
	"""Load player state from checkpoint data"""
	if data.has("position"):
		var pos_array = data["position"]
		global_position = Vector2(pos_array[0], pos_array[1])
