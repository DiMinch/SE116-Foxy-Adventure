@tool
extends AttackBehavior
class_name ShurikenUltiBehavior

func execute_action(player: CharacterBody2D, weapon_data: WeaponData) -> void:
	var ulti_data = weapon_data.get("ultidata") 
	var shuriken_data = ulti_data as ShurikenUlti
	
	if not shuriken_data:
		push_error("ShurikenUltiBehavior: Thiếu UltiData hoặc sai kiểu dữ liệu (Cần ShurikenUlti)!")
		return

	_throw_shuriken(player, shuriken_data)

func _throw_shuriken(player: CharacterBody2D, data: ShurikenUlti) -> void:
	if not data.package_scene:
		push_warning("ShurikenUltiBehavior: Chưa gán package_scene (BigShuriken.tscn)!")
		return

	var shuriken = data.package_scene.instantiate()

	var fire_point = player.get_node_or_null("Direction/FireFactory")
	var spawn_pos = fire_point.global_position if fire_point else player.global_position

	var dir = player.direction
	
	spawn_pos += Vector2(25, 0) * dir

	if shuriken.has_method("setup"):
		shuriken.setup(data, dir, spawn_pos)
	else:
		shuriken.global_position = spawn_pos
		shuriken.scale.x = dir
	
	player.is_ulti = false
	player.get_tree().root.add_child(shuriken)
