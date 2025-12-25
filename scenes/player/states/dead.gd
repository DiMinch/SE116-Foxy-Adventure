extends PlayerState

func _enter():
	obj.change_animation("dead")
	obj.velocity.x = 0
	timer = 2
	AudioManager.play_sound("player_dead")

func _update(delta: float):
	if update_timer(delta):
		if GameManager.current_stage and GameManager.current_stage.has_method("handle_player_failed"):
			GameManager.current_stage.handle_player_failed("Mất quá nhiều máu!")
		else:
			obj.get_tree().reload_current_scene()

func take_damage(_damage: int = 1) -> void:
	pass
