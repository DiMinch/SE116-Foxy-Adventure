extends Node2D
class_name MovingPlatform

@export var path_length: float = 250.0
@export var loop: bool = true
@export var ping_pong: bool = true
@export var auto_start: bool = true
@export_enum("Horizontal", "Vertical") var direction: String = "Vertical"

@onready var path: Path2D = $Path2D
@onready var path_follow: PathFollow2D = $Path2D/PathFollow2D
@onready var animation_player: AnimationPlayer = $Path2D/PathFollow2D/AnimationPlayer
@onready var interactive_area: InteractiveArea2D = $Path2D/PathFollow2D/AnimatableBody2D/InteractiveArea2D

var is_moving: bool = false
var default_loop_mode: int = Animation.LOOP_LINEAR

func _ready() -> void:
	# Create or update the path according to direction and path_length
	_update_path()
	
	# Determine which animation loop mode to use
	default_loop_mode = _choose_loop_mode()
	
	# Start automatically or wait for interaction
	if auto_start:
		interactive_area.visible = false
		_play_animation(default_loop_mode)
	else:
		interactive_area.visible = true

func _play_animation(loop_mode: int):
	# Start the movement animation
	var anim = animation_player.get_animation("move")
	
	# Set the loop mode (linear, ping-pong or none)
	anim.loop_mode = loop_mode
	animation_player.play("move")
	is_moving = true

func _update_path():
	# Dynamic create or update the path curve
	var curve = Curve2D.new()
	curve.add_point(Vector2(0, 0)) # Starting point
	
	# Add the second point based on the selected direction
	if direction == "Horizontal":
		curve.add_point(Vector2(path_length, 0))
	else:
		curve.add_point(Vector2(0, -path_length))
	# Assign the curve to the Path2D node
	path.curve = curve

# Called when the movement animation finishes
func _on_animation_finished(animation_name: String) -> void:
	if animation_name == "move":
		is_moving = false
		if not auto_start:
			interactive_area.visible = true

# Decide which loop mode to apply for the animation
func _choose_loop_mode() -> int:
	if ping_pong == true:
		return Animation.LOOP_PINGPONG
	if loop == true:
		return Animation.LOOP_LINEAR
	return Animation.LOOP_NONE

# Called when the player interacts with the platform
func _on_interactive_area_2d_interacted() -> void:
	if not is_moving:
		interactive_area.visible = false
		auto_start = false
		loop = false
		_play_animation(Animation.LOOP_LINEAR)
