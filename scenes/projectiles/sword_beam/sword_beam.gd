extends HitArea2D

const ANIM_FLY = "play"
const ANIM_HIT = "dead"

var velocity: Vector2 = Vector2.ZERO 
var max_distance: float = 0.0
var start_position: Vector2
@export var speed: float = 800.0

var is_stopping: bool = false
@onready var animated: AnimatedSprite2D = $Direction/AnimatedSprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	super()
	start_position = global_position
	if animated:
		animated.play(ANIM_FLY)

func _physics_process(delta: float) -> void:
	if is_stopping:
		return 

	if velocity != Vector2.ZERO:
		position += velocity * delta
	else:
		var dir = 1 if scale.x > 0 else -1
		position.x += speed * dir * delta

	if max_distance > 0:
		var distance_traveled = global_position.distance_to(start_position)
		
		if distance_traveled >= max_distance:
			dissipate()

func dissipate() -> void:
	if is_stopping: return

	is_stopping = true

	set_deferred("monitoring", false)
	set_deferred("monitorable", false)

	if animated:
		if animated.sprite_frames.has_animation(ANIM_HIT):
			animated.play(ANIM_HIT)
		animated.animation_finished.connect(queue_free, CONNECT_ONE_SHOT)
	else:
		queue_free()


func setup_trajectory(facing_dir: int, angle_offset: float) -> void:
	var base_vector = Vector2.RIGHT if facing_dir == 1 else Vector2.LEFT
	var final_dir = base_vector.rotated(deg_to_rad(angle_offset))
	velocity = final_dir * speed
	rotation = final_dir.angle()

func setup_stats(_damage: int, range_val: Vector2) -> void:
	damage = _damage
	max_distance = range_val.x
	#if range_val.y > 0:
		#var scale_factor = range_val.y / 20.0
		#scale.y = scale_factor
		#scale.x = scale.x * scale_factor
