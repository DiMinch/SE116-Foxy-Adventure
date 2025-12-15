extends AttackBehavior
class_name MeleeAttack

var offset_effect = Vector2.RIGHT * 20

func execute_action(player: Player, _weapon_data: WeaponData) -> void:
	if player.melee_hitbox:
		player.melee_hitbox.set_deferred("monitoring", true)
		
		if player.current_weapon_data.weapon_name == "Spear":
			var direction = player.direction
			var effect = _weapon_data.effect_attack.instantiate()
			effect.global_position = player.projectile_factory.global_position + offset_effect * direction

			if effect.has_method("setup_trajectory"):
				effect.setup_trajectory(direction, player.melee_hitbox)
			player.get_tree().current_scene.add_child(effect)
