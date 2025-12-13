extends AttackBehavior
class_name BoomerangAttack

var count_boomerang: int = 0
var level: int = 1
var max_boomerang: int = 1
var fly_speed: int
var damage: int
var max_range: int
var angles_to_fire: Array[int] = [0]

func execute_action(player: Player, weapon_data: WeaponData) -> void:
	if not weapon_data.projectile_scene:
		return
	
	var base_direction: Vector2 = Vector2(player.direction, 0)
	var num_to_fire = max_boomerang - count_boomerang
	if num_to_fire <= 0:
		return
	
	for i in range(num_to_fire):
		var angle = angles_to_fire[i]
		var final_direction: Vector2 = base_direction.rotated(deg_to_rad(angle))
		
		var projectile = player.projectile_factory.create(weapon_data.projectile_scene)
		if projectile:
			projectile.add_collision_exception_with(player)
			
			if projectile.has_method("setup"):
				projectile.setup(player, final_direction, fly_speed, damage, max_range, null)
			
			count_boomerang += 1
			projectile.connect("returned_or_destroyed", Callable(self, "_on_boomerang_finished"))

func _on_boomerang_finished():
	count_boomerang = max(count_boomerang - 1, 0)

func set_boomerang(player: Player) -> void:
	var index = player.weapon_levels[player.current_slot_index]
	
	max_range = player.current_weapon_data.attack_range.x
	fly_speed = player.current_weapon_data.fly_speed
	damage = player.current_weapon_data.attack
	
	if index > 2:
		max_boomerang = 2
		level = 3
		angles_to_fire = player.current_weapon_data.spread_angles
		fly_speed += player.current_weapon_data.fly_speed_passive
		damage += player.current_weapon_data.attack_passive
	
	elif index == 2:
		max_boomerang = 1
		level = 2
		fly_speed += player.current_weapon_data.fly_speed_passive
		damage += player.current_weapon_data.attack_passive
	
	else:
		max_boomerang = 1
		level = 1
