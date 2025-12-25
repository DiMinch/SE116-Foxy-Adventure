class_name Deadzone
extends Node2D

@onready var area: Area2D = $Area2D

func _ready() -> void:
	# Kết nối tín hiệu body_entered
	area.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node) -> void:
	if body.is_in_group("player"):
		if GameManager.current_stage and GameManager.current_stage.has_method("handle_player_failed"):
			GameManager.current_stage.handle_player_failed("Rơi khỏi map")
