extends Node2D

func collect_blade():
	print("hihi")
	GameManager.player.collected_blade()
	queue_free()
	pass

func _on_interactive_area_2d_interacted() -> void:
	collect_blade()
	pass # Replace with function body.
