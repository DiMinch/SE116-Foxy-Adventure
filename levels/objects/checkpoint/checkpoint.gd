extends Area2D
class_name Checkpoint

signal  checkpoint_activated(checkpoint_id: String)

@export var checkpoint_id: String = ""

var is_activated: bool = false

func _ready() -> void:
	$AnimatedSprite2D.play("idle")
	if checkpoint_id.is_empty():
		checkpoint_id = str(get_path())
	
	if GameManager.current_checkpoint_id == checkpoint_id:
		activate_visual_only()

func  activate_visual_only() -> void:
	is_activated = true

func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		activate()

func activate() -> void:
	if is_activated:
		return
	is_activated = true
	$AnimatedSprite2D.play("active")
	GameManager.save_checkpoint(checkpoint_id)
	GameManager.save_checkpoint_data()
	checkpoint_activated.emit(checkpoint_id)
	print("Checkpoint activated: ", checkpoint_id)
