extends EnemyRunState

@export var movement_range: float = 200.0  # phạm vi di chuyển

var _timer: float = 3.0   # chạy 3 giây rồi chui vào mai

func _enter() -> void:
	_timer = 3.0          # reset mỗi khi vào Run
	super._enter()        # gọi _enter gốc của run.gd

func _update(delta: float) -> void:
	# đếm thời gian để chui vào mai
	_timer -= delta
	if _timer <= 0.0:
		change_state(fsm.states.intoshell)
		return
	
	# logic chạy gốc của run.gd (di chuyển + quay đầu khi chạm tường / sắp rơi)
	super._update(delta)
