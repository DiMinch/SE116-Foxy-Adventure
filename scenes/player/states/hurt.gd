extends PlayerState

var stats_x := -150
var stats_y := -250

const INVINCIBLE_DURATION := 2.0
const BLINK_INTERVAL := 0.1

func _enter() -> void:
	obj.change_animation("hurt")
	# Knockback
	obj.velocity.y = stats_x
	obj.velocity.x = stats_y * sign(obj.velocity.x)

	timer = 0.5
	
	obj.start_invulnerability()

func _update(delta: float):
	if update_timer(delta):
		change_state(fsm.states.idle)
