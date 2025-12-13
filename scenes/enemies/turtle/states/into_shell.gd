extends EnemyState

@export var hide_time: float = 3.0
var _timer: float = 0.0

func _enter() -> void:
	obj.change_animation("into_shell")
	_timer = hide_time
	
	AudioManager.play_sound("player_block")

func _update(delta: float) -> void:
	obj.velocity.x = 0
	_timer -= delta
	if _timer <= 0.0:
		change_state(fsm.states.run)
