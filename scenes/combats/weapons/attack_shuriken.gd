extends AttackBehavior
class_name ShurikenAttack

@export var speed: int
@export var damage: int
@export var max_range: int

var dir: Vector2

func execute_action(player: Player, weapon_data: WeaponData) -> void:
	if not weapon_data.projectile_scene: return
	
	speed = weapon_data.fly_speed
	damage = weapon_data.attack
	max_range = int(weapon_data.attack_range.x)
	dir = Vector2(player.direction, 0)
	
	if player.weapon_levels[player.current_slot_index] == 1:
		var projectile = player.projectile_factory.create(weapon_data.projectile_scene)
		
		if projectile:
			if projectile.has_method("setup"):
				projectile.setup(dir, speed, damage, max_range, null)
	elif player.weapon_levels[player.current_slot_index] == 2:
		var projectile = player.projectile_factory.create(weapon_data.projectile_scene)
		
		if projectile:
			if projectile.has_method("setup"):
				projectile.setup(dir, speed, damage, max_range, weapon_data.effect_bpassive)
	else:
		for angle in weapon_data.spread_angles:
			var final_direction: Vector2 = dir.rotated(deg_to_rad(angle))
			var projectile = player.projectile_factory.create(weapon_data.projectile_scene)
			if projectile:
				projectile.add_collision_exception_with(player)
				
				if projectile.has_method("setup"):
					projectile.setup(final_direction, speed, damage, max_range, weapon_data.effect_bpassive)
