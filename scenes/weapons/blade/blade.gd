extends RigidBody2D

func _ready():
	contact_monitor = true
	max_contacts_reported = 4
	connect("body_entered", Callable(self, "_on_body_entered"))  # <— QUAN TRỌNG

func _on_hit_area_2d_hitted(_area: Variant)->void:
	queue_free()

func _on_body_entered(_body:Node)->void:
	queue_free()
