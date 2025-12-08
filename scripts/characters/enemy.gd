class_name EnemyCharacter
extends BaseCharacter

@export var enemy_type: String = ""
@export var sight: float = 100
@export var spike: float = 50
@export var movement_range: float = 200

# Raycast check wall and fall
var front_ray_cast: RayCast2D
var down_ray_cast: RayCast2D
var left_ray_cast: RayCast2D
var right_ray_cast: RayCast2D
# Detect player area
var detect_player_area: Area2D
var found_player: Player = null
# Hit area
var hit_area: HitArea2D
# Begin/Spawn position
var spawn_position: Vector2

func _ready() -> void:
	add_to_group("Enemy")
	super._ready()
	_init_ray_cast()
	_init_detect_player_area()
	_init_hurt_area()
	_init_hit_area()

func _init_stats() -> void:
	var enemy_stats = StatsManager.get_enemy_stats(enemy_type)
	stats.load_from_dict(enemy_stats)
	
	max_health = get_stat("HEALTH")
	sight = get_stat("SIGHT")
	spike = get_stat("SPIKE")
	movement_speed = get_stat("MOVEMENT_SPEED")
	movement_range = get_stat("MOVEMENT_RANGE")
	jump_speed = get_stat("JUMP_SPEED")
	gravity = get_stat("GRAVITY")
	attack_damage = get_stat("ATTACK_DAMAGE")
	attack_speed = get_stat("ATTACK_SPEED")
	health = self.max_health
	spawn_position = self.global_position

#init ray cast to check wall and fall
func _init_ray_cast():
	if has_node("Direction/FrontRayCast2D"):
		front_ray_cast = $Direction/FrontRayCast2D
	if has_node("Direction/DownRayCast2D"):
		down_ray_cast = $Direction/DownRayCast2D
	if has_node("Direction/RightRayCast2D"):
		right_ray_cast = $Direction/RightRayCast2D
		right_ray_cast.target_position = Vector2(sight, 0)
	if has_node("Direction/LeftRayCast2D"):
		left_ray_cast = $Direction/LeftRayCast2D
		left_ray_cast.target_position = Vector2(-sight, 0)

#init detect player area
func _init_detect_player_area():
	if has_node("Direction/DetectPlayerArea2D"):
		detect_player_area = $Direction/DetectPlayerArea2D
		detect_player_area.body_entered.connect(_on_body_entered)
		detect_player_area.body_exited.connect(_on_body_exited)

# init hurt area
func _init_hurt_area():
	if has_node("Direction/HurtArea2D"):
		var hurt_area = $Direction/HurtArea2D
		hurt_area.hurt.connect(_on_hurt_area_2d_hurt)

# init hit area
func _init_hit_area():
	if has_node("Direction/HitArea2D"):
		hit_area = $Direction/HitArea2D
		hit_area.damage = self.spike
		#hit_area.hitted.connect(_on_hit_area_2d_hitted)

# check touch wall
func is_touch_wall() -> bool:
	if front_ray_cast != null:
		return front_ray_cast.is_colliding()
	return false

# check can fall
func is_can_fall() -> bool:
	if down_ray_cast != null:
		return not down_ray_cast.is_colliding()
	return false

#enable check player in sight
func enable_check_player_in_sight() -> void:
	if(detect_player_area != null):
		detect_player_area.get_node("CollisionShape2D").disabled = false

#disable check player in sight
func disable_check_player_in_sight() -> void:
	if(detect_player_area != null):
		detect_player_area.get_node("CollisionShape2D").disabled = true

func _on_body_entered(_body: CharacterBody2D) -> void:
	var p := _body as Player
	if p:
		found_player = p
		_on_player_in_sight(p.global_position)

func _on_body_exited(_body: CharacterBody2D) -> void:
	found_player = null
	_on_player_not_in_sight()

func _on_hurt_area_2d_hurt(_direction: Vector2, _damage: float) -> void:
	_take_damage_from_dir(_direction, _damage)

# called when player is in sight
func _on_player_in_sight(_player_pos: Vector2):
	pass

# called when player is not in sight
func _on_player_not_in_sight():
	pass

func _take_damage_from_dir(_damage_dir: Vector2, _damage: float):
	fsm.current_state.take_damage(_damage_dir, _damage)

func is_found_player_in_left()->bool:
	if right_ray_cast != null:
		return right_ray_cast.is_colliding()
	return false

func is_found_player_in_right()->bool:
	if left_ray_cast != null:
		return left_ray_cast.is_colliding()
	return false
