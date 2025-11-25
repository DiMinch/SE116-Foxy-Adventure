
extends InteractiveArea2D
@export var key_amount: int =1
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready()->void:
	interaction_available.connect(_on_interaction_available)
	animated_sprite.play("default")  
	super._ready()
func collect_key():
	GameManager.inventory_system.add_key(1)
	animated_sprite.play("pick")
	await animated_sprite.animation_finished

	queue_free()
func _on_interaction_available()->void:
	collect_key()
