extends EnemyState
var timer2:float
func _enter() -> void:
	timer2=0
	obj.is_take_a_rest=false
	obj.change_animation("idle")

func _update(_delta: float) -> void:
	timer2+=_delta
	if timer2>=2:
		change_state(fsm.states.idle)
		
