extends Node2D

@export var str_AniPlay = "play"
@export var duration: float = 5.0

@onready var anima: AnimatedSprite2D = $AnimatedSprite2D
@onready var hitbox = $HitArea2D
@onready var damage: float = 10

func _ready() -> void:
	anima.play(str_AniPlay)
	hitbox.damage = damage
	await get_tree().create_timer(duration).timeout
	queue_free()
