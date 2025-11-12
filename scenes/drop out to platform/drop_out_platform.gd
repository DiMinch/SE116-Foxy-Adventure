extends Node2D


@onready var area: Area2D = $Area2D

func _ready() -> void:
	# Kết nối tín hiệu body_entered
	area.body_entered.connect(_on_body_entered)


func _on_body_entered(body: Node) -> void:
	#print("entered:", body.name, " groups:", body.get_groups())
	if body.is_in_group("player"):
		print("-> is player, reload")
		get_tree().reload_current_scene()
