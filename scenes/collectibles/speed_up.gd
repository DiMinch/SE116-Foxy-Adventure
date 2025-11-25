
extends InteractiveArea2D
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready()->void:
	interaction_available.connect(_on_interaction_available)
	super._ready()
func collect_speed_up():
	GameManager.player.speed_up(3,5)
	queue_free()
func _on_interaction_available()->void:
	collect_speed_up()	
