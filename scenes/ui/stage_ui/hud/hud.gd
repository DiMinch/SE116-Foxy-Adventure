extends MarginContainer

var stage_node: Node = null

func _ready() -> void:
	stage_node = get_parent().get_parent()
	print("Node: ", stage_node)
	if !stage_node:
		stage_node = get_parent()
	$HBoxContainer/SettingsTextureButton.pressed.connect(_on_settings_texture_button_pressed)

func _on_settings_texture_button_pressed() -> void:
	var popup_settings = load("res://scenes/ui/stage_ui/hud/settings_popup.tscn").instantiate()
	stage_node.add_child(popup_settings)
	
	if popup_settings.has_signal("turned_back"):
		popup_settings.turned_back.connect(_on_settings_popup_turned_back)

func _on_settings_popup_turned_back():
		if stage_node.has_method("_on_turn_back_pressed"):
			stage_node._on_turn_back_pressed()
		else:
			push_error("Stage thiếu hàm '_on_turn_back_pressed' để xử lý quay lại.")
