extends InteractiveArea2D
class_name CollectibleBase

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

func _ready() -> void:
	animated_sprite.play("default")
	set_collision_mask_value(2, true)
	interaction_available.connect(_on_available)
	super._ready()

func _on_available() -> void:
	collect()

# Override
func collect() -> void:
	pass

func play_and_free(anim: String) -> void:
	collision_shape.set_deferred("disabled", true)
	if animated_sprite and anim != "":
		animated_sprite.play(anim)
		await animated_sprite.animation_finished
	queue_free()
