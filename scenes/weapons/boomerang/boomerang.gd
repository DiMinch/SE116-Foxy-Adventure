extends RigidBody2D
class_name Boomerang

enum State { OUTBOUND, RETURNING }

signal returned_or_destroyed

var current_state = State.OUTBOUND
var player_target: Player = null
var return_force: float = 800.0

@export var max_range: float = 300.0
var current_damage: int = 0
var travel_speed: float = 0.0
var start_position: Vector2
@onready var hitbox = $HitArea2D
@onready var effect_scene: PackedScene

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func _physics_process(_delta: float) -> void:
	if current_state == State.OUTBOUND:
		if start_position.distance_to(global_position) >= max_range:
			current_state = State.RETURNING
			collision_mask &= ~(1 << 0)
			linear_velocity *= -0.5
	
	elif current_state == State.RETURNING:
		if is_instance_valid(player_target):
			var dir = (player_target.global_position - global_position).normalized()
			
			var return_speed = travel_speed * 1.2
			
			linear_velocity = dir * return_speed
			
			gravity_scale = 0
			apply_central_force(Vector2.ZERO)
			apply_force(Vector2.ZERO)
			angular_velocity = 0
			
			if global_position.distance_to(player_target.global_position) < 20:
				emit_signal("returned_or_destroyed")
				queue_free()

func setup(spawner: Player, direction: Vector2, speed: float, damage: int, _max_range: int, _effect: PackedScene) -> void:
	if spawner:
		player_target = spawner
		add_collision_exception_with(spawner)
	
	max_range = _max_range
	current_damage = damage
	travel_speed = speed
	start_position = global_position
	
	linear_velocity = direction * speed
	current_state = State.OUTBOUND
	
	hitbox.damage = current_damage

func _on_body_entered(_body: Node) -> void:
	if current_state == State.OUTBOUND:
		current_state = State.RETURNING
		collision_mask &= ~(1 << 0)
		set_angular_velocity(0)
		set_linear_velocity(Vector2.ZERO)
		
		var rebound_speed = travel_speed * 0.8
		var rebound_direction = -linear_velocity.normalized() * rebound_speed
		
		set_linear_velocity(rebound_direction)
		gravity_scale = 0
		return
	
	elif current_state == State.RETURNING:
		emit_signal("returned_or_destroyed") 
		queue_free()

func _on_reached_player():
	if is_instance_valid(player_target):
		player_target.check_attack = true
	queue_free()
