extends RigidBody2D
@export var attack_damage=1
@export var movement_speed: float = 200.0 
func _ready() -> void:
	pass
	#linear_velocity = Vector2(0, movement_speed)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
		queue_free()
		return
	if body is TileMapLayer:
		queue_free()
		return
	queue_free()
