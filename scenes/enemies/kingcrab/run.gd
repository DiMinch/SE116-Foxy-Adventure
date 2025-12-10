extends EnemyRunState

const MapScene = "Stage"
const strPlayer = "Player"

var is_left: bool = true
var player: Player


func _enter() -> void:

	super._enter()

func _update(delta: float) -> void:
	# giữ logic chạy / quay đầu gốc
	super._update(delta)
	# --- PHẦN CHECK PLAYER GIỮ NGUYÊN ---
	
	# --- LẤY PLAYER MỖI LẦN CHECK, GIỐNG CODE CŨ CỦA MÀY ---
	var stage := find_parent(MapScene)
	if stage == null:
		return
	player = stage.find_child(strPlayer) as Player
	if player == null or not is_instance_valid(player):
		return
	

	var pos: Vector2 = obj.global_position

	var to_player: Vector2 = player.global_position - pos
	# xác định player bên trái / phải (nếu mày còn cần dùng is_left)
	is_left = to_player.x < 0.0
	# KHOẢNG CÁCH CHUẨN: chỉ cần abs(to_player.x), abs(to_player.y)
	var dx: float = abs(to_player.x)
	var dy: float = abs(to_player.y)
	# player nằm trong “hộp” 200 x 150 quanh native thì cho attack
	if dx <= obj.sight and dy <=30 and _is_player_in_move_range():
		#print(">>> CHANGE TO ATTACK, dx=", dx, " dy=", dy)  # debug xem có chạy vào không
		if is_opposite()==false:
			obj.turn_around()
			
		if obj.is_atk1:
			obj.is_atk1=false
			change_state(fsm.states.attack1)
		else :
			obj.is_atk1=true
			change_state(fsm.states.attack2)

func is_opposite() -> bool:
	var stage := obj.find_parent(MapScene)
	if stage == null:
		return false
		
	var p := stage.find_child(strPlayer) as Player
	if p == null or not is_instance_valid(p):
		return false
	
	var kingcrab_x: float = obj.global_position.x
	var player_x: float = p.global_position.x
	var looking_dir: float = obj.direction
	var player_dir: float = sign(player_x - kingcrab_x)
	return looking_dir == player_dir
	
func _is_player_in_move_range() -> bool:
	var stage := obj.find_parent(MapScene)
	if stage == null:
		return false
	
	var p := stage.find_child(strPlayer) as Player
	if p == null or not is_instance_valid(p):
		return false

	# tâm vùng di chuyển của king_crab
	var center_x: float = obj.spawn_position.x
	var left_limit: float = center_x - obj.movement_range
	var right_limit: float = center_x + obj.movement_range

	var player_x: float = p.global_position.x
	return player_x >= left_limit-50 and player_x <= right_limit+50
