extends RigidBody2D
@export var attack_damage:int

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
	
func setup(pelican: Pelican2) -> void:
	attack_damage = pelican.spike
