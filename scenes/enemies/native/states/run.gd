extends EnemyRunState

const MapScene = "Stage"
const strPlayer = "Player"

var is_left: bool = true
var player: Player
var _time: float = 0.0

func _enter() -> void:
	_time = 0.0
	super._enter()

func _update(delta: float) -> void:
	# giữ logic chạy / quay đầu gốc
	super._update(delta)
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
