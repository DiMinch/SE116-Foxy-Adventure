extends MarginContainer

@export var skill_slot: PackedScene
@export var setting_popup: PackedScene = preload("res://scenes/ui/stage_ui/hud/settings_popup.tscn")

@onready var coin_label = $HBoxContainer/VBoxContainer/BoxContainer/ItemsHBoxContainer/CoinLabel
@onready var key_label = $HBoxContainer/VBoxContainer/BoxContainer/ItemsHBoxContainer/KeyLabel
@onready var time_label = $HBoxContainer/VBoxContainer/BoxContainer/TimeLabel

@onready var skill_bar = $HBoxContainer/VBoxContainer/SkillBar
@onready var block_overlay = $HBoxContainer/VBoxContainer/SkillBar/BlockSkillSlot
@onready var dash_overlay = $HBoxContainer/VBoxContainer/SkillBar/DashSkillSlot
@onready var ulti_overlay = $HBoxContainer/VBoxContainer/SkillBar/UltiSkillSlot

var active_powerup_slots = {}

func _ready() -> void:
	await get_tree().process_frame
	$HBoxContainer/SettingsTextureButton.pressed.connect(_on_settings_texture_button_pressed)
	# Setup items
	GameManager.inventory_system.item_changed.connect(_on_items_changed)
	_update_labels("coins", GameManager.inventory_system.get_currency("coins"))
	_update_labels("keys", GameManager.inventory_system.get_currency("keys"))

func _on_settings_texture_button_pressed() -> void:
	var popup_settings = setting_popup.instantiate()
	get_parent().add_child(popup_settings)

func _process(_delta: float) -> void:
	_update_time_display()
	
	if not GameManager.player:
		return
	var player = GameManager.player
	
	# Update static skills
	_update_static_skill(dash_overlay, player.timer_dash, player.DASH_COOLDOWN, player.is_cooldown_dash)
	_update_static_skill(dash_overlay, player.timer_dash, player.DASH_COOLDOWN, player.is_cooldown_block)
	# Update ulti
	var max_ulti = 50
	_update_static_skill(ulti_overlay, max_ulti - player.current_ulti_cooldown, max_ulti, player.current_ulti_cooldown <= 0)

func _on_items_changed(item_type: String, new_amount: int) -> void:
	_update_labels(item_type, new_amount)

func _update_labels(type: String, amount: int):
	if type == "coins":
		coin_label.text = str(amount)
	elif type == "keys":
		key_label.text = str(amount)

func _update_time_display():
	var stage = GameManager.current_stage
	if not stage and stage.start_time <= 0:
		return
	
	var total_seconds_allowed = stage.minute_limit * 60
	var elapsed = (Time.get_ticks_msec() / 1000.0) - stage.start_time
	var time_left = max(total_seconds_allowed - elapsed, 0.0)
	
	time_label.text = _format_time(time_left)
	if time_left < 15.0:
		time_label.modulate = Color.RED
	else:
		time_label.modulate = Color.WHITE

func _format_time(seconds: float) -> String:
	var m = int(seconds / 60)
	var s = int(seconds) % 60
	return "%02d:%02d" % [m, s]

func _update_static_skill(overlay, current, max_val, is_ready):
	if not is_ready:
		overlay.visible = true
		overlay.get_node("CooldownOverlay").value = (1.0 - (current / max_val)) * 100
	else:
		overlay.visible = false
