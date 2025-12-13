extends EnemyState
var _anim: AnimatedSprite2D

func _enter():
	obj.change_animation("returnpincers")
	_anim = obj.get_node("Direction/AnimatedSprite2D")
	#var frames := _anim.sprite_frames
	if not _anim.animation_finished.is_connected(_on_anim_finished):
		_anim.animation_finished.connect(_on_anim_finished)
func _on_anim_finished():
	# Quan trọng: kiểm tra đúng animation
	if _anim.animation == "returnpincers":
		change_state(fsm.states.dizzy)
