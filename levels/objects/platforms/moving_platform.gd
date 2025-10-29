extends Path2D
class_name MovingPlatformPath

@export var move_speed: float = 0.2
@export var loop: bool = true
@export var ping_pong: bool = true
@export var auto_start: bool = false

@onready var path_follow: PathFollow2D = $PathFollow2D
@onready var animation_player: AnimationPlayer = $AnimationPlayer
@onready var interactive_area: InteractiveArea2D = $PathFollow2D/AnimatableBody2D/InteractiveArea2D

var is_moving: bool = false
var default_loop_mode: int = Animation.LOOP_LINEAR

func _ready() -> void:
	if curve != null and curve.get_point_count() > 0:
		var first_point: Vector2 = curve.get_point_position(0)
		path_follow.progress_ratio = 0.0
		path_follow.position = first_point
		
	default_loop_mode = _choose_loop_mode()
	
	if auto_start:
		interactive_area.visible = false
		_play_animation(default_loop_mode)
	else:
		interactive_area.visible = true

func _play_animation(loop_mode: int):
	var anim = animation_player.get_animation("move")
	anim.loop_mode = loop_mode
	animation_player.play("move")
	is_moving = true
	animation_player.animation_finished.connect(_on_animation_finished, CONNECT_ONE_SHOT)

func _on_animation_finished(animation_name: String) -> void:
	if animation_name == "move":
		is_moving = false
		if not auto_start:
			interactive_area.visible = true

func _choose_loop_mode() -> int:
	if ping_pong == true:
		return Animation.LOOP_PINGPONG
	if loop == true:
		return Animation.LOOP_LINEAR
	return Animation.LOOP_NONE

func _on_interactive_area_2d_interacted() -> void:
	if not is_moving:
		interactive_area.visible = false
		auto_start = false
		loop = false
		_play_animation(Animation.LOOP_NONE)
