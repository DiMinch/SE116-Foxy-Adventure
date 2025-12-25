extends Node2D
class_name Grass

@onready var dead_anima: AnimatedSprite2D = $Direction/DeadAnimatedSprite2D
@onready var alive_anima: AnimatedSprite2D = $Direction/AliveAnimatedSprite2D
@onready var detect_player: Area2D = $Direction/Area2D
var is_alive: bool = true
var is_dead: bool = false

func _ready():
	alive_anima.visible = true
	dead_anima.visible = false
	pass

func _on_hurt_area_2d_hurt(_direction: Variant, _damage: Variant) -> void:
	if is_dead:
		return
	if is_alive:
		alive_anima.visible = false
		dead_anima.visible = true
	if _damage > 0:
		dead_anima.play("hit")
		await dead_anima.animation_finished
		dead_anima.play("dead")
		is_dead = true
	else:
		alive_anima.play("dead")
		await alive_anima.animation_finished
		alive_anima.visible = false
		dead_anima.visible = true
		dead_anima.play("idle")
	pass

func _on_area_2d_body_entered(_body: Player) -> void:
	pass
