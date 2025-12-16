extends RigidBody2D

@export var initial_speed: float = 400.0      # tốc độ bắn ngang ban đầu
@export var attack_range: float = 400.0       # tầm lăn tối đa (theo trục X)
@export var stop_speed: float = 40.0          # ngưỡng coi như đã dừng (tốc độ gần = 0)

@export var sudden_drop_factor: float = 0.35  # % tốc độ còn lại sau va chạm, thấp hơn thì coi là giảm đột ngột
@export var min_speed_for_drop_check: float = 80.0 # chỉ check “giảm đột ngột” nếu trước đó nhanh hơn ngưỡng này

@onready var Hit= $HitArea2D
var _start_pos: Vector2
var _direction: float = 1.0
var _initialized := false
var _is_exploding := false
var _last_speed_x: float = 0.0               # lưu speed.x frame trước để so sánh

# Hàm này được gọi ngay sau khi factory tạo viên đạn
func setup(direction: int, range: float, speed: float, attack_damage:int) -> void:
	Hit.damage=attack_damage
	_direction = direction
	if _direction == 0:
		_direction = 1
	
	attack_range = max(range, 0.0)
	initial_speed = speed

	# Node đã đặt đúng vị trí spawn → lấy luôn làm start_pos
	_start_pos = global_position

	# Bắn ngang theo hướng của war_lord
	linear_velocity = Vector2(initial_speed * _direction, 0.2)
	sleeping = false
	_initialized = true
	_last_speed_x = abs(linear_velocity.x)

func _ready() -> void:
	# Phòng trường hợp ai đó quên gọi setup()
	if not _initialized:
		_start_pos = global_position
		linear_velocity = Vector2(initial_speed * _direction, 0.0)
		sleeping = false
	_last_speed_x = abs(linear_velocity.x)

func _physics_process(_delta: float) -> void:
	if _is_exploding:
		return
	# 1) Đi quá tầm (tính theo trục X) thì nổ
	if attack_range > 0.0:
		var dist_x: float = abs(global_position.x - _start_pos.x)
		if dist_x >= attack_range:
			explode()
			return
	# ----- 2) Check giảm vận tốc .x đột ngột -----
	var current_speed_x: float = abs(linear_velocity.x)
	
	# Nếu frame trước chạy đủ nhanh, mà frame này tụt xuống quá nhiều → coi như đâm mạnh vào gì đó
	if _last_speed_x > min_speed_for_drop_check and current_speed_x < _last_speed_x * sudden_drop_factor:
		explode()
		return
	# ----- 3) Nếu tốc độ gần như bằng 0 thì nổ -----
	# dùng length_squared cho nhẹ, so với stop_speed^2
	var speed_sq: float = linear_velocity.length_squared()
	if speed_sq <= stop_speed * stop_speed:
		explode()
		return
	# ----- 4) Nếu RigidBody đi vào trạng thái ngủ (sleeping) → cũng nổ -----
	if sleeping:
		explode()
		return
	# Cập nhật speed_x cho frame sau
	_last_speed_x = current_speed_x

func explode() -> void:
	
	AudioManager.play_sound("explosion")
	
	shake()
	if _is_exploding:
		return
	_is_exploding = true

	# Bật hit để gây sát thương trong lúc nổ
	$HitArea2D/CollisionShape2D.set_deferred("disabled", false)
	$HitArea2D.monitoring = true 

	linear_velocity = Vector2.ZERO
	sleeping = true

	rotation=0.0
	$Sprite2D.visible=false
	var anim=$AnimatedSprite2D
	anim.visible=true
	anim.play("default")
	await anim.animation_finished
	queue_free()
	

func _on_body_entered(body: Node) -> void:
	# chạm player => trừ máu + nổ
	if body.is_in_group("player"):
		explode()
		
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
	camera.shake_ground(0.3,40)
	
	
