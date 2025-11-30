extends PlayerState
var _block_shape: CollisionShape2D
func _enter() -> void:
	obj.change_animation('block')
	_block_shape = obj.get_node('Direction/StaticBody2D/CollisionShape2D') as CollisionShape2D
	_block_shape.disabled=false
	timer = 0.5
	
	pass

func _update(delta: float):
	if update_timer(delta):
		_block_shape.disabled=true
		change_state(fsm.states.idle)
	
