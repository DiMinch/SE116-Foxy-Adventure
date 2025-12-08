extends AttackBehavior
class_name BoomerangUltiBehavior

func execute_action(player: CharacterBody2D, weapon_data: WeaponData) -> void:
	var ulti_data = weapon_data.get("ultidata") as BoomerangUlti
	if not ulti_data: return

	var cost_damage = int(player.health * ulti_data.self_hp_cost)
	
	if cost_damage > 0:
		if player.has_method("take_damage"):
			player.take_damage(cost_damage)
		else:
			player.health -= cost_damage
			print("Player hy sinh ", cost_damage, " máu để phóng Boomerang!")

	_throw_boomerang(player, ulti_data)

func _throw_boomerang(player: CharacterBody2D, data: BoomerangUlti) -> void:
	if not data.package_scene: return
	
	var boomerang = data.package_scene.instantiate()
	
	var fire_point = player.get_node_or_null("Direction/FireFactory")
	var spawn_pos = fire_point.global_position if fire_point else player.global_position
	
	var dir = player.direction

	if boomerang.has_method("setup"):
		boomerang.setup(data, dir, spawn_pos, player)
	
	player.get_tree().root.add_child(boomerang)
