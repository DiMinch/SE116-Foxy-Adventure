extends RigidBody2D

@export var speed: float = 400
@onready var Hit = $HitArea2D
var start_pos: Vector2
var target_pos: Vector2
var owner_crab: Node2D          # Con king_crab
var going_out: bool = true      # true: đang bay ra, false: đang bay về

@onready var anim: AnimatedSprite2D = $AnimatedSprite2D

var timer = 0.0
var ok = false

# Hàm này sẽ được gọi từ attack_2.gd
func setup(start: Vector2, target: Vector2, crab: Node2D, custom_speed: float = -1.0, attack_damage: float = -1) -> void:
	Hit.damage=attack_damage
	start_pos = start
	target_pos = target
	owner_crab = crab
	global_position = start

	if custom_speed > 0.0:
		speed = custom_speed

	going_out = true

func _ready() -> void:
	# Không cho trọng lực kéo xuống
	gravity_scale = 0.0
	timer = 0
	ok = false

@export var max_lifetime: float = 3
var life: float = 0.0

func _physics_process(delta: float) -> void:
	life += delta
	if life >= max_lifetime:
		queue_free()
		return
	timer = timer + delta
	if timer >= 0.8:
		ok = true
	
	if speed <= 0.0:
		return

	if going_out:
		anim.play("shoot")
		var to_target := target_pos - global_position
		var dist := to_target.length()

	# Điều kiện: đi đủ gần target hoặc hết thời gian bay ra
		if dist <= speed * delta or ok:
		# KHÔNG teleport nữa, giữ nguyên chỗ nó đang đứng (có thể là chỗ dính tường)
			going_out = false
			linear_velocity = Vector2.ZERO
			return

		linear_velocity = to_target.normalized() * speed

	else:
		anim.play("return")

		var to_crab := Vector2.ZERO
		var dist := 0.0

		if owner_crab != null and is_instance_valid(owner_crab):
			to_crab = owner_crab.global_position - global_position
			dist = to_crab.length()
		else:
			to_crab = start_pos - global_position
			dist = to_crab.length()

		if dist <= 50:
			queue_free()
		else:
			linear_velocity = to_crab.normalized() * speed


	# Luôn cập nhật hướng sprite theo vận tốc
	_update_flip()

func _update_flip() -> void:
	# Nếu đang bay sang trái (x < 0) thì lật; sang phải thì bỏ lật
	if linear_velocity.x != 0.0:
		anim.flip_h = linear_velocity.x > 0.0

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	shake()
	pass # Replace with function body.


const MapScene = "Stage"
const strCamera = "Camerarig"
var is_left: bool = true
var camera: CharacterBody2D
func shake():
	var stage := find_parent(MapScene)
	if stage == null:
		return
	camera = stage.find_child(strCamera) as CharacterBody2D
	if camera == null or not is_instance_valid(camera):
		return
	camera.shake_ground(0.2,30)
