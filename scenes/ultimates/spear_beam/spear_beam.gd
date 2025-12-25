extends Node2D

const IDLE = "idle"
@onready var anima: AnimatedSprite2D = $Direction/AnimatedSprite2D
@onready var spear: HitArea2D

func _ready():
	anima.play(IDLE)
	await anima.animation_finished
	spear.set_deferred("monitoring", false)
	queue_free()

func setup_trajectory(facing_dir: int, spear_hitbox: HitArea2D) -> void:
	rotation = 0.0 if facing_dir == 1.0 else PI
	spear = spear_hitbox
