extends Control

@onready var username_input: LineEdit = $Panel/VBoxContainer/UsernameInput
@onready var password_input: LineEdit = $Panel/VBoxContainer/PasswordInput
@onready var login_button: Button = $Panel/VBoxContainer/HBoxContainer/LoginButton
@onready var register_button: Button = $Panel/VBoxContainer/HBoxContainer/RegisterButton
@onready var message_label: Label = $Panel/VBoxContainer/Message

@export_file("*.tscn") var main_screen = "res://scenes/screens/main_screen.tscn"
@export_file("*.tscn") var first_level = "res://levels/level1.tscn"

func _ready() -> void:
	get_tree().paused = false
	message_label.text = "Chào mừng đến với trò chơi!"

func _on_login_button_pressed() -> void:
	var username = username_input.text.strip_edges()
	var password = password_input.text
	var error_message = UserSystem.login(username, password)
	
	if error_message.is_empty():
		# Change to Main Screen
		show_message("Đăng nhập thành công! Đang tải dữ liệu ...", false)
		await get_tree().create_timer(1.0).timeout
		var completed_levels = UserSystem.meta_data.get("levels_completed", {})
		if not completed_levels.has("1"):
			GameManager.has_started_session = true
			GameManager.change_stage(first_level, "Begin")
		else:
			GameManager.change_stage(main_screen, "Begin")
	else:
		show_message(error_message, true)
		password_input.clear()

func _on_register_button_pressed() -> void:
	var username = username_input.text.strip_edges()
	var password = password_input.text
	var error_message = UserSystem.register_user(username, password)
	
	if error_message.is_empty():
		show_message("Đăng ký thành công! Hãy nhấn Đăng nhập.", false)
	else:
		show_message(error_message, true)
		password_input.clear()

func show_message(text: String, is_error: bool = false):
	if is_error:
		message_label.add_theme_color_override("font_color", Color.RED)
		message_label.text = "Lỗi: " + text
	else:
		message_label.add_theme_color_override("font_color", Color.GREEN)
		message_label.text = text
