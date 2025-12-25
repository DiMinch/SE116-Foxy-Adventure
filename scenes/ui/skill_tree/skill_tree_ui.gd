extends Control

@onready var coin_label = $CanvasLayer/VBoxContainer/CoinLabel

func _ready() -> void:
	PlayerData.coins_changed.connect(_on_coins_changed)
	_update_text(PlayerData.player_coins)
	get_tree().paused = true

func _on_coins_changed(new_amount: int) -> void:
	_update_text(new_amount)

func _update_text(amount: int) -> void:
	coin_label.text = str(amount)

func _on_close_texture_button_pressed() -> void:
	get_tree().paused = false
	queue_free()
