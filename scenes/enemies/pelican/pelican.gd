extends EnemyCharacter
class_name EnemyPelican

@export var pelican_data: PelicanData
@export var bullet_data: BulletData
@export var bullet_speed: float
@onready var bullet_factory := $Direction/BulletFactory

# Thuộc tính đặc thù (nếu enemy có hành vi riêng)
@export var flight_height: int = 0       # Độ cao bay (0 nếu không bay)
@export var appear_duration: float = 0.0 # Thời gian xuất hiện trước khi biến mất
@export var spike_interval: float = 0.0  # Khoảng thời gian thả spike (0 nếu không thả)

const MapScene = "Stage"
const strPlayer = "Player"

var player: Player
var start_x: float
var direction_Player: Vector2 = Vector2(1, 0)
var is_attack: bool = false
var appear_timer: float = 0.0

func _ready() -> void:
	if pelican_data:
		name = pelican_data.name
		gravity = pelican_data.gravity
		health = pelican_data.health
		spike = pelican_data.spike
		sight = pelican_data.sight
		movement_range = pelican_data.movement_range
		
		flight_height = pelican_data.flight_height
		appear_duration = pelican_data.appear_duration
		spike_interval = pelican_data.spike_interval
	
	if bullet_data:
		bullet_speed = bullet_data.attack_speed
	
	appear_timer = appear_duration
	start_x = global_position.x
	enemy_type = "Pelican"
	fsm = FSM.new(self, $States, $States/Fly)
	player = find_parent(MapScene).find_child(strPlayer)
	super._ready()
	
	AudioManager.play_sound("pelican")

func fire() -> void:
	var bullet := bullet_factory.create() as RigidBody2D
	var dx = player.global_position.x - global_position.x
	var dy = player.global_position.y - global_position.y
	
	var direction_Pelican_to_Player = Vector2(dx, dy).normalized()
	var shooting_velocity = bullet_speed * direction_Pelican_to_Player
	print(shooting_velocity)
	bullet.apply_impulse(shooting_velocity)
	
func _on_hurt_area_2d_hurt(_direction: Variant, _damage: Variant) -> void:
	fsm.current_state.take_damage(_damage)

func _on_player_in_sight(_player_pos: Vector2):
	is_attack = true

func _on_player_not_in_sight():
	is_attack = false

func _update_movement(delta: float) -> void:
	super._update_movement(delta)
	_update_flight_height(delta)
	
	if appear_duration > 0:
		appear_timer -= delta
		if appear_timer <= 0:
			_fly_away()

func _update_flight_height(delta: float) -> void:
	if down_ray_cast.is_colliding():
		var ground_y = down_ray_cast.get_collision_point().y
		var target_y = ground_y - flight_height
		global_position.y = lerp(global_position.y, target_y, 5 * delta)

func get_is_attack() -> bool:
	return is_attack

func _fly_away() -> void:
	velocity.y = -movement_speed
	fsm.change_state(fsm.states.fly) 
	if global_position.y < -100:
		queue_free()

func is_out_of_fly_range() -> bool:
	var distance = global_position.x - start_x
	
	if abs(distance) >= movement_range:
		if (distance * direction > 0):
			return true
	return false
