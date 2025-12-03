extends Area2D
class_name HitArea2D

# damage of hit
@export var damage = 1

# signal when hit area
signal hitted(area)

func _ready() -> void:
	area_entered.connect(_on_area_entered)

# called when hit area
func hit(hurt_area):
	if(hurt_area.has_method("take_damage")):
		var hit_dir:Vector2 = hurt_area.global_position - global_position
		hurt_area.take_damage(hit_dir.normalized(), damage)

# called when area entered
func _on_area_entered(area):
	hit(area)
	hitted.emit(area)

func _on_hitted(_area: Variant) -> void:
	pass # Replace with function body.
