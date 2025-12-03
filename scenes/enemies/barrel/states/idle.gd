extends EnemyState

# Các mốc thời gian (tính từ lúc BẮT ĐẦU 1 chu trình)
@export var fire_times: PackedFloat32Array = [
	0.0,  # viên 1
	1.0,  # viên 2
	2.0,  # viên 3
	2.1,  # viên 4
	2.2   # viên 5
]

@export var cycle_pause: float = 1.0  # nghỉ 1s sau viên 5, rồi mới bắt đầu chu trình mới

var _initialized: bool = false
var _time_in_cycle: float = 0.0   # thời gian trôi trong CHU TRÌNH hiện tại
var _next_index: int = 0          # đang chờ bắn viên thứ mấy trong fire_times


func _enter() -> void:
	obj.change_animation("idle")
	# chỉ setup lần đầu, không reset khi từ Shoot quay lại
	if not _initialized:
		_initialized = true
		_time_in_cycle = 0.0
		_next_index = 0

func _update(delta: float) -> void:
	if fire_times.is_empty():
		return
	
	# tăng thời gian của chu trình hiện tại
	_time_in_cycle += delta
	# chiều dài 1 chu trình = thời gian viên cuối + thời gian nghỉ
	var cycle_duration := fire_times[fire_times.size() - 1] + cycle_pause
	# với mảng trên: 2.2 + 1.0 = 3.2s
	# nếu đã vượt qua hết 1 chu trình -> bắt đầu chu trình mới
	if _time_in_cycle >= cycle_duration:
		_time_in_cycle -= cycle_duration   # giữ lại phần thời gian dư cho chính xác
		_next_index = 0
	
	# nếu vẫn còn viên trong chu trình hiện tại
	if _next_index < fire_times.size():
		var target_time := fire_times[_next_index]
		
		# đến (hoặc qua) thời điểm bắn tiếp theo
		if _time_in_cycle >= target_time:
			# gọi state shoot -> shoot bắn 1 viên rồi quay lại Idle
			change_state(fsm.states.shoot)
			_next_index += 1
