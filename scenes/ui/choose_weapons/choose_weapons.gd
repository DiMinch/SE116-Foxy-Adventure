extends Control

@onready var weapons = $MarginContainer/VBoxContainer/WeaponsContainer.get_children()
@onready var message_label = $MarginContainer/VBoxContainer/MessageLabel

@onready var slot_1 = $MarginContainer/VBoxContainer/EquipContainer/Panel/HBoxContainer/Slot1
@onready var slot_2 = $MarginContainer/VBoxContainer/EquipContainer/Panel/HBoxContainer/Slot2

var selected_slot: int = 0

func _ready() -> void:
	slot_1.get_node("TextureRect").gui_input.connect(_on_slot_clicked.bind(0))
	slot_2.get_node("TextureRect").gui_input.connect(_on_slot_clicked.bind(1))
	
	for weapon_node in weapons:
		weapon_node.weapon_selected.connect(_on_weapon_selected)
	update_loadout_display()
	_highlight_slot()
	message("Hãy chọn vũ khí bạn thích")
	get_tree().paused = true

func _on_slot_clicked(event: InputEvent, slot_index: int):
	if event is InputEventMouseButton and event.is_pressed():
		if slot_index == 1 and not PlayerData.is_second_slot_unlocked:
			message("Slot 2 chưa mở khóa!")
			return
		selected_slot = slot_index
		_highlight_slot()
		message("Đang chọn Slot" + str(slot_index + 1))

func _on_weapon_selected(w_name: String):
	var other_slot = 1 if selected_slot == 0 else 0
	
	if PlayerData.current_loadout[other_slot] == w_name:
		message(w_name + " đã được lắp ở ô còn lại")
		return
	
	PlayerData.set_loadout_slot(selected_slot, w_name)
	update_loadout_display()
	_highlight_slot()
	message("Đã lắp " + w_name + " vào Slot " + str(selected_slot + 1))

func update_loadout_display():
	_render_slot(slot_1, PlayerData.current_loadout[0])
	
	# Slot 2
	if PlayerData.is_second_slot_unlocked:
		slot_2.modulate = Color(1.0, 1.0, 1.0)
		_render_slot(slot_2, PlayerData.current_loadout[1])
	else:
		slot_2.modulate = Color(0.3, 0.3, 0.3)
		_render_slot(slot_2, "")

func _render_slot(slot_node: ColorRect, w_name: String):
	var text_rect = slot_node.get_node("TextureRect")
	if w_name != "" and PlayerData.weapon_table.has(w_name):
		text_rect.texture = PlayerData.weapon_table[w_name].icon
		slot_node.color = Color(0.8, 0.8, 0)
	else:
		text_rect.texture = null
		slot_node.color = Color(0.1, 0.1, 0.1)

func _highlight_slot():
	var active_slot = slot_1 if selected_slot == 0 else slot_2
	var inactive_slot = slot_2 if selected_slot == 0 else slot_1
	
	active_slot.color.a = 1.0
	inactive_slot.color.a = 0.4

func hide_popup():
	get_tree().paused = false
	queue_free()

func _on_overlay_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_popup() # Replace with function body.

func _on_close_texture_button_pressed() -> void:
	hide_popup()

func message(text: String) -> void:
	message_label.text = text
