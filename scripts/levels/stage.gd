extends Node2D
class_name Stage

func _enter_tree() -> void:
	# Handle portal spawning first
	GameManager.current_stage = self
	
func _ready() -> void:
	fade_in_screen()
	
	if not GameManager.respawn_at_portal():
		GameManager.respawn_at_checkpoint()

func fade_in_screen() -> void:
	var fade_layer = get_tree().root.get_node_or_null("FadeLayer")
	if fade_layer:
		await fade_layer.fade_in()
