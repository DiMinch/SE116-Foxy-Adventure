extends Control

func hide_popup():
	queue_free()

func _on_overlay_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_popup() # Replace with function body.

func _on_close_texture_button_pressed() -> void:
	hide_popup()

func _on_blade_button_pressed() -> void:
	PlayerData.set_loadout_slot(0, "Blade")
	message("Blade đã được trang bị")

func _on_spear_button_pressed() -> void:
	PlayerData.set_loadout_slot(1, "Spear")
	message("Spear đã được trang bị")

func message(text: String) -> void:
	$MessageLabel.visible = true
	$MessageLabel.text = text
	await get_tree().create_timer(2).timeout
	$MessageLabel.visible = false
	PlayerData.load_upgrades()
