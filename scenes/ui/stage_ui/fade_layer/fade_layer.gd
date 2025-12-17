extends CanvasLayer
class_name FadeLayer

@onready var rect: ColorRect = $ColorRect
@onready var animation: AnimationPlayer = $AnimationPlayer

func _ready():
	# Kiểm tra xem các node đã load chưa
	if not rect or not animation:
		push_error("FadeLayer: Missing child nodes!")
		return

func fade_out() -> void:
	if not animation:
		return
	if animation.has_animation("fade_out"):
		animation.play("fade_out")
		await animation.animation_finished

func fade_in() -> void:
	if not animation:
		return
	if animation.has_animation("fade_in"):
		animation.play("fade_in")
		await animation.animation_finished
