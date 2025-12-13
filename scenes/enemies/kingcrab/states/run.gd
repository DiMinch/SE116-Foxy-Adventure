extends EnemyRunState

const MapScene = "Stage"
const strPlayer = "Player"

var is_left: bool = true
var player: Player

var timer_count_down: float = 0.0              # đếm 2s cho lần detect đầu
var can_atk_after_count_down: bool = false     # true = đã chờ xong 2s trong lần detect này
var _hurt_timer_running: bool = false          # để không tạo nhiều timer khi bị hurt


func _enter() -> void:
	super._enter()
	# KHÔNG reset timer_count_down / can_atk_after_count_down ở đây
	# để khi từ attack quay về run mà player vẫn trong vùng thì đánh ngay


func _update(delta: float) -> void:
	# --- đang bị đánh thì set timer hồi phục ---
	if obj.is_being_hurt and not _hurt_timer_running:
		_hurt_timer_running = true
		set_ready_atk()  # có await bên trong

	# giữ logic chạy / quay đầu gốc
	super._update(delta)

	# --- LẤY PLAYER ---
	var stage := find_parent(MapScene)
	if stage == null:
		return
	player = stage.find_child(strPlayer) as Player
	if player == null or not is_instance_valid(player):
		return

	var pos: Vector2 = obj.global_position
	var to_player: Vector2 = player.global_position - pos

	is_left = to_player.x < 0.0
	var dx: float = abs(to_player.x)
	var dy: float = abs(to_player.y)

	# player có đang trong vùng tấn công không
	var in_attack_zone: bool = (
		dx <= obj.sight and
		dy <= 200.0 and
		_is_player_in_move_range() and
		not obj.is_being_hurt
	)

	if in_attack_zone:
		# frame đầu tiên của LẦN DETECT NÀY (từ ngoài vùng bước vào)
		if not obj.start_detect_player:
			obj.start_detect_player = true
			timer_count_down = 0.0
			can_atk_after_count_down = false   # chưa chờ 2s

		# quay mặt về phía player nếu đang nhìn ngược
		if not is_opposite():
			obj.turn_around()

		# nếu CHƯA từng chờ đủ 2s trong lần detect này -> đứng im và đếm
		if not can_atk_after_count_down:
			obj.velocity.x = 0.0
			timer_count_down += delta
			if timer_count_down >= 2.0:
				can_atk_after_count_down = true  # từ giờ trở đi được phép đánh ngay

		# nếu đã chờ xong 2s (hoặc từ attack quay lại run mà player vẫn trong vùng)
		if can_atk_after_count_down:
			# đổi sang state attack, lần sau quay lại run mà player vẫn trong vùng
			# thì can_atk_after_count_down vẫn = true => đánh luôn, không chờ lại
			if obj.is_atk1:
				obj.is_atk1 = false
				change_state(fsm.states.attack1)
			else:
				obj.is_atk1 = true
				change_state(fsm.states.attack2)

	else:
		# PLAYER RA KHỎI VÙNG -> reset, lần sau vào lại phải chờ 2s
		if obj.start_detect_player:
			obj.start_detect_player = false
			timer_count_down = 0.0
			can_atk_after_count_down = false


func set_ready_atk() -> void:
	# chờ 0.5s sau khi bị đánh rồi mới cho đánh tiếp
	await get_tree().create_timer(0.0).timeout
	obj.is_being_hurt = false
	_hurt_timer_running = false


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
	return player_x >= left_limit - 50.0 and player_x <= right_limit + 50.0
