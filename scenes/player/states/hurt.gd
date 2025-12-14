extends PlayerState

var stats_x := -150
var stats_y := -250

const INVINCIBLE_DURATION := 2.0
const BLINK_INTERVAL := 2

const HURT = "hurt"

func _enter() -> void:
	obj.change_animation(HURT)
	print("Player current health: ", obj.health, "/", obj.max_health)
	# Knockback
	obj.velocity.y = stats_x
	obj.velocity.x = stats_y * sign(obj.velocity.x)

	obj.start_invulnerability()
	timer = 0.5
	
	AudioManager.play_sound("player_hurt")

func _update(delta: float):
	if update_timer(delta):
		change_state(fsm.states.idle)
