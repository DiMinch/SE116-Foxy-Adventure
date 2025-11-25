extends InteractiveArea2D
@export var hp_amount: int =1
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready()->void:
	interaction_available.connect(_on_interaction_available)
	super._ready()
func collect_fruit():
	GameManager.inventory_system.add_fruit(20)
	
	
	queue_free()
func _on_interaction_available()->void:
	collect_fruit()
