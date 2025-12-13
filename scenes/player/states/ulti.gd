extends PlayerState

func _enter() -> void:
	obj.is_attack = true

	use_ultimate()

func _update(delta: float) -> void:
	if update_timer(delta):
		change_state(fsm.states.idle)

func _exit() -> void:
	if obj.current_slot_index:
		obj.current_ulti_cooldown_weapon1 = obj.current_weapon_data.ultidata.cool_down * obj.de_cooldown
	else:
		obj.current_ulti_cooldown_weapon2 = obj.current_weapon_data.ultidata.cool_down * obj.de_cooldown
	obj.is_attack = false
	obj.is_invulnerable = false

func use_ultimate() -> void:
	var weapon = obj.current_weapon_data

	if weapon and "attack_ulti" in weapon and weapon.attack_ulti:

		weapon.attack_ulti.execute_action(obj, weapon)

		if weapon.ultidata:
			timer = weapon.ultidata.timer
		else:
			timer = 2.0
			print("UltiState: Không tìm thấy UltiData, dùng timer mặc định 2s")
	
	else:
		timer = 0.5
