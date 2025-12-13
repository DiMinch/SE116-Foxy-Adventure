extends RigidBody2D
@export var attack_damage:int
@onready var Hit= $HitArea2D
func _ready() -> void:
	
	pass
	#linear_velocity = Vector2(0, movement_speed)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		queue_free()
		return
	if body is TileMapLayer:
		queue_free()
		return
	queue_free()
	
func setup(damage :int) -> void:
	Hit.damage = damage
