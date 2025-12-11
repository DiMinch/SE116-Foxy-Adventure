extends RigidBody2D

@export var min_travel_time: float = 0.20
#@export var max_travel_time: float = 0.8
#export var default_travel_time: float = 0.4

@export var rotation_offset_deg: float = 0.0  # chỉnh cho khớp hướng sprite

var travel_time: float = 0.35
var _start_pos: Vector2
var _target_pos: Vector2
var _active: bool = false
var _exploded: bool = false
var _life: float = 0.0
var _last_pos: Vector2

func setup(start: Vector2, target: Vector2, time: float = -1.0,max_travel_time:float=-1.0,default_travel_time:float=-1.0) -> void:
	_start_pos = start
	_target_pos = target
	global_position = start
	_last_pos = start
	if time > 0.0:
		travel_time = clamp(time, min_travel_time, max_travel_time)
	else:
		travel_time = clamp(default_travel_time, min_travel_time, max_travel_time)

	var gravity_value := ProjectSettings.get_setting("physics/2d/default_gravity") as float
	var g := Vector2(0.0, gravity_value)

	var T := travel_time
	var v0 := (_target_pos - _start_pos - 0.5 * g * T * T) / T
	freeze = false
	gravity_scale = 1.0
	linear_velocity = v0

	_active = true
	_exploded = false
	_life = 0.0


func _physics_process(delta: float) -> void:
	if not _active:
		return

	_life += delta

	 #XOAY THEO ĐƯỜNG ĐI THỰC TẾ
	var dir := global_position - _last_pos
	if dir.length_squared() > 0.0001:
		rotation = dir.angle() + deg_to_rad(rotation_offset_deg+90)
	_last_pos = global_position

	# tránh bay mãi nếu không va chạm
	if _life >= travel_time * 1.5:
		explode()
	

func explode() -> void:
	if _exploded:
		return
	_exploded = true
	_active = false
	$HitArea2d/CollisionShape2D.set_deferred("disabled", false)
	$HitArea2d.monitoring = true 
	#$Sprite2D2.visible = true
	await get_tree().physics_frame

	# Dừng chuyển động vật lý cho chắc
	linear_velocity = Vector2.ZERO
	sleeping = true
	# Đợi 0.2s rồi xóa
	rotation=0.0
	$Sprite2D.visible=false
	var anim=$AnimatedSprite2D
	anim.visible=true
	anim.play("default")
	await get_tree().create_timer(0.2).timeout
	$HitArea2d/CollisionShape2D.set_deferred("disabled", true)
	await anim.animation_finished
	queue_free()


func _on_HitArea2d_body_entered(_body: Node) -> void:
	explode()


func _on_HitArea2d_area_entered(_area: Area2D) -> void:
	explode()


func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		explode()
	if body is TileMapLayer:
		explode()
	return
