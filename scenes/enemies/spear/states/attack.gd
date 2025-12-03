extends EnemyState

var _start_x: float = 0.0
var _hit_shape: CollisionShape2D
var _timer : float = 0.0

func _enter() -> void:
	_timer = 2.0
	# lưu vị trí bắt đầu
	_start_x = obj.global_position.x
	print("Spear start attack")
	# bật anim tấn công
	obj.change_animation("attack")
	print("Spear start animation")
	# trượt theo hướng mặt với tốc độ attack_speed
	obj.velocity.x = obj.direction * obj.attack_speed
	
	# bật collision của HitArea2d
	var hit_area := obj.get_node("Direction/HitArea2D") as Area2D
	if hit_area:
		_hit_shape = hit_area.get_node("CollisionShape2D") as CollisionShape2D
		if _hit_shape:
			_hit_shape.disabled = false

func _update(delta: float) -> void:
	# luôn giữ vận tốc trượt theo hướng mặt
	_timer -= delta
	obj.velocity.x = obj.direction * obj.attack_speed
	if _should_turn_around():
		obj.turn_around()
	# kiểm tra đã trượt đủ khoảng sight chưa
	var moved: float = abs(obj.global_position.x - _start_x)
	
	if moved >= obj.sight or _timer <= 0:
		_end_attack()

func _exit() -> void:
	# phòng trường hợp state bị đổi đột ngột
	_disable_hit_area()
	obj.velocity.x = 0.0

func _end_attack() -> void:
	obj.velocity.x = 0.0
	_disable_hit_area()
	# quay về state trước (thường là Idle / Run)
	change_state(fsm.states.idle)

func _disable_hit_area() -> void:
	if _hit_shape and is_instance_valid(_hit_shape):
		_hit_shape.disabled = true

func _should_turn_around()->bool:
	if obj.is_touch_wall():
		return true
	if obj.is_on_floor() and obj.is_can_fall():
		return true
	return false
