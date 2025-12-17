extends Control

@onready var username_input: LineEdit = $Panel/VBoxContainer/UsernameInput
@onready var password_input: LineEdit = $Panel/VBoxContainer/PasswordInput
@onready var login_button: Button = $Panel/VBoxContainer/HBoxContainer/LoginButton
@onready var register_button: Button = $Panel/VBoxContainer/HBoxContainer/RegisterButton
@onready var message_label: Label = $Panel/VBoxContainer/Message

var main_screen_path: String = "res://scenes/screens/main_screen.tscn"

func _ready() -> void:
	if UserSystem.current_username:
		get_tree().change_scene_to_file(main_screen_path)
	message_label.text = "Chào mừng đến với trò chơi!"

func _on_login_button_pressed() -> void:
	var username = username_input.text.strip_edges()
	var password = password_input.text
	
	var error_message = UserSystem.login(username, password)
	
	if error_message.is_empty():
		message_label.text = "Đăng nhập thành công! Đang tải dữ liệu ..."
		# Change to Main Screen
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file(main_screen_path)
	else:
		message_label.text = "Lỗi đăng nhập: " + error_message
		password_input.clear()

func _on_register_button_pressed() -> void:
	var username = username_input.text.strip_edges()
	var password = password_input.text
	
	var error_message = UserSystem.register_user(username, password)
	if error_message.is_empty():
		message_label.text = "Đăng ký thành công! Hãy nhấn Đăng nhập."
		password_input.clear()
	else:
		message_label.text = "Lỗi đăng ký: " + error_message
		password_input.clear()
