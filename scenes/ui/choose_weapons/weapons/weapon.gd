extends Control

signal weapon_selected(w_name)

@export var weapon_texture: Texture2D
@export var weapon_name: String = ""

@onready var button = $VBoxContainer/TextureButton
@onready var label = $VBoxContainer/Label

func _ready() -> void:
	# Init Label
	label.text = weapon_name
	# Init Button
	button.texture_normal = weapon_texture
	button.texture_hover = weapon_texture
	button.texture_pressed = weapon_texture
	button.pressed.connect(_on_texture_button_pressed)
	#button.mouse_entered.connect(_on_texture_button_mouse_entered)
	# Check unlocked
	update_availability()

func update_availability():
	var is_unlocked = PlayerData.unlocked_weapons.get(weapon_name, false)
	if is_unlocked:
		modulate = Color(1.0, 1.0, 1.0)
		button.disabled = false
	else:
		modulate = Color(0.3, 0.3, 0.3)
		button.disabled = true

func _on_texture_button_pressed() -> void:
	weapon_selected.emit(weapon_name)
