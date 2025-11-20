extends "res://scenes/characters/player/states/run.gd"

const MapScene = "Stage"
const strPlayer = "Player"

var is_left: bool = true
var player: Player
var _time: float = 0.0

@export var movement_range: float = 200.0  # phạm vi nó được phép chạy qua (tâm là vị trí lúc vào state)

var _start_x: float
var _left_limit: float
var _right_limit: float


func _enter() -> void:
	_time = 0.0

	# lấy vị trí hiện tại làm tâm phạm vi movement_range
	_start_x = obj.global_position.x
	var half := movement_range * 0.5
	_left_limit = _start_x - half
	_right_limit = _start_x + half

	super._enter()


func _update(delta: float) -> void:
	# giữ logic chạy / quay đầu gốc
	super._update(delta)

	# GIỚI HẠN TRONG movement_range
	var x := obj.global_position.x
	if obj.direction > 0 and x > _right_limit:
		obj.turn_around()
	elif obj.direction < 0 and x < _left_limit:
		obj.turn_around()

	# --- PHẦN CHECK PLAYER GIỮ NGUYÊN ---

	_time += delta
	if _time < 0.5:
		return
	_time = 0.0

	# --- LẤY PLAYER MỖI LẦN CHECK, GIỐNG CODE CŨ CỦA MÀY ---
	var stage := find_parent(MapScene)
	if stage == null:
		return
	player = stage.find_child(strPlayer) as Player
	if player == null or not is_instance_valid(player):
		return

	# vị trí native
	var pos: Vector2 = obj.global_position
	# vector native -> player
	var to_player: Vector2 = player.global_position - pos

	# xác định player bên trái / phải (nếu mày còn cần dùng is_left)
	is_left = to_player.x < 0.0

	# KHOẢNG CÁCH CHUẨN: chỉ cần abs(to_player.x), abs(to_player.y)
	var dx: float = abs(to_player.x)
	var dy: float = abs(to_player.y)

	# player nằm trong “hộp” 200 x 150 quanh native thì cho attack
	if dx <= obj.sight and dy <= 150.0:
		print(">>> CHANGE TO ATTACK, dx=", dx, " dy=", dy)  # debug xem có chạy vào không
		change_state(fsm.states.attack)
