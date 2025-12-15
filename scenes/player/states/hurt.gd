extends PlayerState

var stats_x := -150
var stats_y := -250

const INVINCIBLE_DURATION := 2.0
const BLINK_INTERVAL := 2

const HURT = "hurt"

func _enter() -> void:
	shake()
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

const MapScene = "Stage"
const strCamera = "Camerarig"
var is_left: bool = true
var camera: CharacterBody2D
func shake():
	var stage := find_parent(MapScene)
	if stage == null:
		return
	camera = stage.find_child(strCamera) as CharacterBody2D
	if camera == null or not is_instance_valid(camera):
		return
	camera.shake_ground(0.3,15)
