extends EnemyState

const MapScene = "Stage"
const strPlayer = "Player"

var _anim: AnimatedSprite2D
var player: Player
var is_change = false

func _enter() -> void:
	# đứng yên khi attack
	obj.velocity.x = 0
	
	# đổi sang anim tấn công
	if is_opposite():
		obj.change_animation("attack")
	else:
		is_change = true
		obj.turn_around()
		obj.change_animation("attack")
	
	# lấy AnimatedSprite2D
	_anim = obj.get_node("Direction/AnimatedSprite2D") as AnimatedSprite2D
	
	# đảm bảo animation "attack" không loop
	var frames := _anim.sprite_frames
	if frames and frames.has_animation("attack"):
		frames.set_animation_loop("attack", false)
	
	# nối signal animation_finished -> gọi khi anim attack chạy hết
	if not _anim.animation_finished.is_connected(_on_attack_finished):
		_anim.animation_finished.connect(_on_attack_finished)
	
	# 🔹 BẮT ĐẦU ĐẾM 0.2s RỒI MỚI NÉM DỪA
	_start_throw_after_delay()

func _update(_delta: float) -> void:
	# trong lúc attack chỉ đứng yên, KHÔNG ném thêm
	obj.velocity.x = 0

# 🔹 HÀM MỚI: CHỜ 0.2s RỒI MỚI NÉM
func _start_throw_after_delay() -> void:
	await get_tree().create_timer(0.4).timeout

	# state có thể đã bị đổi giữa chừng -> check cho chắc
	if !is_inside_tree():
		return
	if fsm.current_state != self:
		return

	_throw_coconuts()

func _throw_coconuts() -> void:
	var factory: Node2D = obj.get_node("Direction/Node2DFactory")
	# vị trí spawn: trước mặt native một chút
	var x_offset := 12.0
	var y_offset := -8.0
	var spawn_pos := obj.global_position + Vector2(x_offset * obj.direction, y_offset)
	
	# DỪA BÊN PHẢI
	var right = factory.create()
	right.global_position = spawn_pos
	right.start_throw(Vector2(1, -0.8), obj.attack_speed, obj.attack_damage)
	
	# DỪA BÊN TRÁI
	var left = factory.create()
	left.global_position = spawn_pos
	left.start_throw(Vector2(-1, -0.8), obj.attack_speed, obj.attack_damage)

func _on_attack_finished() -> void:
	# animation attack kết thúc -> quay lại state trước (thường là Run)
	if is_change == true:
		obj.turn_around()
	change_state(fsm.previous_state)

func is_opposite() -> bool:
	var stage := obj.find_parent(MapScene)
	if stage == null:
		return false
	
	var p := stage.find_child(strPlayer) as Player
	if p == null or not is_instance_valid(p):
		return false
	
	var native_x: float = obj.global_position.x
	var player_x: float = p.global_position.x
	var looking_dir: float = obj.direction
	var player_dir: float = sign(player_x - native_x)
	return looking_dir == player_dir
