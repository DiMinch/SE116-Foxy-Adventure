extends AspectRatioContainer

@onready var health_bar = $HealthTextureProgressBar
@onready var label: Label = $HealthTextureProgressBar/Label

var max_health: int = 0

func _ready() -> void:
	if GameManager.player:
		GameManager.player.health_changed.connect(_on_player_health_changed)
		_on_player_health_changed(GameManager.player.health, GameManager.player.max_health)

func _on_player_health_changed(current, max_val):
	health_bar.max_value = max_val
	var tween = create_tween()
	tween.tween_property(health_bar, "value", current, 0.2)
	change_label(current, max_val)

func change_label(current_val: int, max_val: int) -> void:
	label.text = str(current_val) + "/" + str(max_val)
