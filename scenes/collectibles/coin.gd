extends InteractiveArea2D
@export var coin_amount: int =1
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D

func _ready()->void:
	interaction_available.connect(_on_interaction_available)
	animated_sprite.play("default")  
	super._ready()
func collect_coin():
	GameManager.inventory_system.add_coin(1)
	animated_sprite.play("pick")
	
	queue_free()
func _on_interaction_available()->void:
	collect_coin()
