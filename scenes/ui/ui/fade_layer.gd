extends CanvasLayer

@onready var rect: ColorRect = $ColorRect
@onready var animation: AnimationPlayer = $AnimationPlayer

func fade_out() -> void:
	if animation.has_animation("fade_out"):
		animation.play("fade_out")
		await animation.animation_finished

func fade_in() -> void:
	if animation.has_animation("fade_in"):
		animation.play("fade_in")
		await animation.animation_finished
