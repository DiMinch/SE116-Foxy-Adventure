extends EnemyState

@export var shoot_delay: float = 0.3
var shoot_timer: float = 0.0

var shoot_sfx_player: AudioStreamPlayer2D = null

func _enter() -> void:
	obj.velocity.x=0
	obj.change_animation("shoot")
	shoot_timer = shoot_delay
	timer = 0.5
	
	if obj.has_node("AudioStreamPlayer2D"):
		shoot_sfx_player = obj.get_node("AudioStreamPlayer2D")
	if shoot_sfx_player:
		shoot_sfx_player.play()

func _update(delta :float) -> void:
	if shoot_timer > 0:
		shoot_timer -= delta
		if shoot_timer <= 0:
			obj.fire()
	
	if update_timer(delta):
		change_state(fsm.previous_state)
