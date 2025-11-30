extends RigidBody2D
class_name Shuriken

@export var max_range: float = 300.0

@onready var hitbox = $HitArea2D
@onready var effect_scene: PackedScene

var start_position: Vector2
var current_damage: int = 0
var travel_speed: float = 0.0

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	
	if not body_entered.is_connected(_on_body_entered):
		body_entered.connect(_on_body_entered)

func setup(direction: Vector2, speed: float, damage: int, _max_range: int, effect: PackedScene) -> void:
	current_damage = damage
	travel_speed = speed
	linear_velocity = direction * speed
	hitbox.damage = damage
	effect_scene = effect
	max_range = _max_range
	
	start_position = global_position

func _physics_process(_delta: float) -> void:
	if start_position.distance_to(global_position) >= max_range:
		queue_free()

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	if effect_scene == null:
		queue_free()
		return
	var enemy_center_pos = _area.global_position
	var space_state = get_world_2d().direct_space_state
	
	var query = PhysicsRayQueryParameters2D.create(
		enemy_center_pos + Vector2(0, 10),
		enemy_center_pos + Vector2(0, 200)
	)
	
	query.collide_with_areas = true 
	query.collision_mask = 1
	
	var result = space_state.intersect_ray(query)
	
	if result.is_empty():
		print("⚠️ Lỗi RayCast: Không tìm thấy mặt đất trong phạm vi quét (Có thể là vực sâu).")
		queue_free()
		return
	
	var ground_y = result.position.y
	
	var effect_instance = effect_scene.instantiate() as Node2D
	get_tree().current_scene.add_child(effect_instance)
	
	var final_pos = Vector2(position.x, ground_y)
	effect_instance.global_position = final_pos
	queue_free()

func _on_body_entered(_body: Node) -> void:
	queue_free()
