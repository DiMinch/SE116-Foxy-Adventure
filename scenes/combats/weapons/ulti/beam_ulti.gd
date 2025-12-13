@tool
extends AttackBehavior
class_name BladeUltiBehavior

func execute_action(player: CharacterBody2D, weapon_data: WeaponData) -> void:

	if not "ultidata" in weapon_data and not "timer" in weapon_data:
		push_error("WeaponData thiếu biến ultidata or timer!")
		return

	_perform_barrage(player, weapon_data)


func _perform_barrage(player: CharacterBody2D, data: WeaponData) -> void:
	var duration_val = float(data.timer)
	var shot_count = 6
	player.velocity.x = 0

	if data.ultidata and "count" in data.ultidata:
		shot_count = data.ultidata.count

	var wait_time = duration_val / float(shot_count)
	
	for i in range(shot_count):
		if not is_instance_valid(player): return

		var angle = -15 + (i % 3 * 10)
		_spawn_beam(player, data, angle)
		
		await player.get_tree().create_timer(wait_time).timeout

func _spawn_beam(player: CharacterBody2D, data: WeaponData, angle: float) -> void:
	
	if not data.ultidata or not "package_scene" in data.ultidata: return
	var beam_scene = data.ultidata.package_scene
	if beam_scene == null: return

	var beam = beam_scene.instantiate()

	var fire_point = player.get_node_or_null("Direction/FireFactory")
	beam.global_position = fire_point.global_position if fire_point else player.global_position

	var dir_node = player.get_node_or_null("Direction")
	var facing_dir = 1
	if dir_node and dir_node.scale.x < 0: facing_dir = -1

	if beam.has_method("setup_trajectory"):
		beam.setup_trajectory(facing_dir, angle)
	else:
		if beam.has_method("set_direction"): beam.set_direction(facing_dir)

	if "range" in data.ultidata:
		var range_val = data.ultidata.range
		var damage = data.ultidata.damage_unit
		if beam.has_method("setup_stats"):
			beam.setup_stats(damage, range_val)

	player.get_tree().root.add_child(beam)
