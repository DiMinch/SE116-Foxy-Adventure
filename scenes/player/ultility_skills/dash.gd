extends PlayerState
class_name DashState

var dash_time := 0.3
var dash_speed := 600
var dash_damage := 0
var invulnerable := false

func _enter() -> void:
	timer = 0
	obj.change_animation("dash")
	AudioManager.play_sound("player_dash")

	obj.is_invulnerable = invulnerable

	if dash_damage > 0:
		obj.melee_hitbox.monitoring = true
		obj.melee_hitbox.damage = dash_damage

func _update(delta):
	timer += delta

	obj.velocity.x = dash_speed * obj.direction

	if timer >= dash_time:
		_exit_dash()

func _exit_dash():
	obj.velocity.x = 0
	obj.is_invulnerable = false
	obj.melee_hitbox.monitoring = false
	change_state(fsm.states.idle)
