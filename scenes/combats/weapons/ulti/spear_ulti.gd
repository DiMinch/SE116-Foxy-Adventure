@tool
extends AttackBehavior
class_name SpearUltiBehavior

func execute_action(player: CharacterBody2D, weapon_data: WeaponData) -> void:
	var melee_data = weapon_data as MeleeData
	if not melee_data or not melee_data.ultidata: return
	
	var dash_data = melee_data.ultidata as UltiData
	if not dash_data: return

	_perform_drill_dash(player, dash_data)

func _perform_drill_dash(player: Player, data: UltiData) -> void:

	player.is_invulnerable = true
	
	var hitbox = player.melee_hitbox
	var original_transform = Transform2D()
	var original_damage = 1
	var target_distance = data.range.x

	player.melee_hitbox.set_deferred("monitoring", true)
	player.spear_shape.set_deferred("disabled", true)
	player.spear_ulti_shape.set_deferred("disabled", false)

	if "damage" in hitbox:
		original_damage = hitbox.damage
		hitbox.damage = data.damage_unit

	var start_pos = player.global_position
	var timer = 0.0

	while timer < data.timer:
		if not is_instance_valid(player): return

		player.velocity.x = data.speed * player.direction
		player.velocity.y = 0 
		player.move_and_slide()

		var current_dist = start_pos.distance_to(player.global_position)

		if current_dist >= target_distance:
			break 

		timer += player.get_process_delta_time()
		await player.get_tree().process_frame

	player.velocity.x = 0
	player.spear_shape.set_deferred("disabled", false)
	player.spear_ulti_shape.set_deferred("disabled", true)
	await player.get_tree().create_timer(0.5).timeout
	player.is_invulnerable = false
	hitbox.damage = original_damage
