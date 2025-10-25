extends PlayerState

@export var blade_delay: float = 0.3   # thời gian trễ trước khi về lại idle/run
var blade_timer: float = 0.0

func _enter() -> void:
	# ném đúng 1 lần khi vào state
	obj.Throw()
	blade_timer = 0.0

func _update(delta: float) -> void:
	blade_timer += delta
	if blade_timer >= blade_delay:
		# quay lại idle/run tuỳ đang có di chuyển không
		var dir := Input.get_action_strength("right") - Input.get_action_strength("left")
		if abs(dir) > 0.1 and obj.is_on_floor():
			change_state(fsm.states.run)
		else:
			change_state(fsm.states.idle)
