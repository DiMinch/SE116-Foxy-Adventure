extends Area2D
class_name HurtArea2D

# signal when hurt
signal hurt(direction: Vector2, damage: float)

# called when take damage
func take_damage(direction: Vector2, damage: float):
	LOG(damage)
	hurt.emit(direction, damage)

func LOG(info_damage):
	print("[%s] take damage = %s" % [get_parent().name, info_damage])
