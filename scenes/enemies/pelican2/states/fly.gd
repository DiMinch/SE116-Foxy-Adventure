extends EnemyState

var front_ray_cast: RayCast2D

const MapScene = "Stage"
const strPlayer = "Player"
var player: Player
var prepare_go_away := false

# --- di chuyển ---
@export var speed: float              # tốc độ bay ngang
@export var patrol_range: float      # KHOẢNG BAY MẶC ĐỊNH (sửa biến này nếu không dùng mốc)

# Có thể đặt 2 mốc trái/phải trong scene cho dễ canh (tùy chọn)
@export_node_path var left_marker_path: NodePath
@export_node_path var right_marker_path: NodePath

# cận trên/dưới của hành trình
var _left_x: float
var _right_x: float
var _origin_set := false
@export var count_down:float

func _enter() -> void:
	# đặt khoảng tuần tra một lần khi vào Fly
	patrol_range=obj.movement_range
	speed=obj.movement_speed
	front_ray_cast = $Direction/FrontRayCast2D
	_set_patrol_bounds()
	obj.change_animation("fly")
	obj.velocity.y = 0
	if obj.direction == 0:
		obj.change_direction(1) # đảm bảo có hướng ban đầu


func _update(delta: float) -> void:
	# bay ngang
	obj.velocity.x = speed * obj.direction
	obj.velocity.y = 0
	obj.move_and_slide()
	if count_down >0:
		count_down -=delta
	# quay đầu khi tới mép (chỉ khi chưa chuẩn bị bay đi)
	var x := obj.global_position.x
	if not prepare_go_away:
		if obj.direction > 0 and x >= _right_x:
			obj.change_direction(-1)
		elif obj.direction < 0 and x <= _left_x:
			obj.change_direction(1)

		# chỉ check tường khi chưa go_away
		if obj.is_touch_wall():
			print("hihi")
			obj.change_direction(obj.direction * -1)

	# lịch bắn: chuyển sang state Attack để thả đạn
	if is_can_attack() and obj.dem < 5 and count_down<=0:
		count_down=2
		change_state(fsm.states.attack)

	# bắn đủ 5 lần thì bay đi rồi xoá
	if obj.dem >= 5 and not prepare_go_away:
		go_away()


func go_away() -> void:
	prepare_go_away = true
	# tiếp tục bay thẳng theo hướng hiện tại
	obj.velocity.x = speed * obj.direction
	obj.velocity.y = 0
	# cho nó bay 1 đoạn rồi tự xoá
	await get_tree().create_timer(2.0).timeout
	obj.queue_free()


func _set_patrol_bounds() -> void:
	if _origin_set:
		return
	_origin_set = true

	# Nếu có đặt mốc thì dùng mốc; không thì dùng patrol_range quanh vị trí hiện tại
	if left_marker_path != NodePath() and right_marker_path != NodePath() \
	and obj.has_node(left_marker_path) and obj.has_node(right_marker_path):
		_left_x = obj.get_node(left_marker_path).global_position.x
		_right_x = obj.get_node(right_marker_path).global_position.x
		if _left_x > _right_x:
			var t = _left_x
			_left_x = _right_x
			_right_x = t
	else:
		var cx := obj.global_position.x
		_left_x = cx - patrol_range * 0.5
		_right_x = cx + patrol_range * 0.5


func is_can_attack() -> bool:
	var stage := obj.find_parent(MapScene)
	if stage == null:
		return false

	player = stage.find_child(strPlayer) as Player
	if player == null or not is_instance_valid(player):
		return false

	var pos: Vector2 = obj.global_position
	# vector -> player
	var to_player: Vector2 = player.global_position - pos

	# KHOẢNG CÁCH CHUẨN: chỉ cần abs(to_player.x), abs(to_player.y)
	var dx: float = abs(to_player.x)
	var dy: float = abs(to_player.y)

	if dx <= 28.0 and dy <= 300.0:
		return true
	return false
