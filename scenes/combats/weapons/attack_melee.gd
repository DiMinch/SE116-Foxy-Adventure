extends AttackBehavior
class_name MeleeAttack

func execute_action(player: Player, weapon_data: WeaponData) -> void:
	if player.melee_hitbox:
		player.melee_hitbox.set_deferred("monitoring", true)
