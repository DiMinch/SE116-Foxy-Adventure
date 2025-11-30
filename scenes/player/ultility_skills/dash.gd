extends PlayerState

@export var _timer = 0
func _enter() -> void:
	#obj.change_animation('dash')
	_timer = 0

func _update(_delta):
	_timer += _delta
	if _timer >= 0.3:
		change_state(fsm.states.idle)
	obj.velocity.x += obj.dash_speed * obj.direction
