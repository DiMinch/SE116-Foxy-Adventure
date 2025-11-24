extends RigidBody2D

@export var bullet_info: BulletData
@onready var hit: HitArea2D = $HitArea2D

func _ready() -> void:
	hit.damage = bullet_info.attack_damage

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	queue_free()

func _on_body_entered(_body: Node) -> void:
	queue_free()
