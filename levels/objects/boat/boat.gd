extends AnimatableBody2D
class_name Boat

@export_enum("Right", "Left") var start_direction := "Right"
@export var move_speed: float = 100.0
@export var move_range: float = 200.0
@export var auto_start: bool = false
@export var wait_before_move: float = 1.0

@onready var body_sprite: Sprite2D = $Sprite2D
@onready var sail_sprites: AnimatedSprite2D = $AnimatedSprite2D
@onready var interact_area: InteractiveArea2D = $InteractiveArea2D
@onready var front_ray_cast: RayCast2D = $FrontRayCast2D

var direction := 1
var start_position: Vector2
var is_moving: bool = false

func _ready() -> void:
	sail_sprites.play("default")
	start_position = position
	direction = 1 if start_direction == "Right" else -1
	_update_sprite_flip()
	
	front_ray_cast.enabled = true
	_update_raycast_direction()
	
	if auto_start:
		await get_tree().create_timer(wait_before_move).timeout
		start_moving()

func _physics_process(delta: float) -> void:
	if not is_moving:
		return
	if front_ray_cast.is_colliding():
		stop_moving()
		return
	
	position.x += move_speed * delta * direction
		
	if abs(position.x - start_position.x) > move_range:
		#direction *= -1
		#_update_sprite_flip()
		#_update_raycast_direction()
		stop_moving()

func _on_interactive_area_2d_interacted() -> void:
	front_ray_cast.force_raycast_update()
	if is_moving:
		return
	if front_ray_cast.is_colliding():
		direction *= -1
		_update_sprite_flip()
		_update_raycast_direction()
		await get_tree().create_timer(0.1).timeout
	start_moving()

func start_moving():
	is_moving = true

func stop_moving():
	is_moving = false

func _update_sprite_flip():
	var flip = direction < 0
	if sail_sprites:
		sail_sprites.flip_h = flip

func _update_raycast_direction():
	front_ray_cast.target_position.x = 60 * direction
