@tool
extends AttackBehavior
class_name SpearUltiBehavior

var original_damage := 1

func execute_action(player: CharacterBody2D, weapon_data: WeaponData) -> void:
	var melee_data = weapon_data as MeleeData
	if not melee_data or not melee_data.ultidata: return
	
	var dash_data = melee_data.ultidata as UltiData
	if not dash_data: return

	_setup_spear_ulti(player, dash_data)

func _setup_spear_ulti(player: Player, data: UltiData) -> void:
	player.is_ulti = true
	player.is_invulnerable = true

	var hitbox = player.melee_hitbox
	original_damage = hitbox.damage
	hitbox.damage = data.damage_unit
	hitbox.monitoring = true

	player.spear_shape.disabled = true
	player.spear_ulti_shape.disabled = false
	
	player.velocity.x = data.speed * player.direction
	player.velocity.y = 0
	
	player.move_and_slide()

func reset(obj: Player) -> void:
	obj.velocity.x = 0
	await obj.get_tree().physics_frame
	obj.is_invulnerable = false
	obj.is_ulti = false

	var hitbox = obj.melee_hitbox
	hitbox.monitoring = false
	hitbox.damage = hitbox.basic_damage

	obj.spear_shape.disabled = false
	obj.spear_ulti_shape.disabled = true
