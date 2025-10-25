@tool
extends Node

@onready var icon: Sprite2D = $Icon
@export var icon_pos: Vector2 = Vector2(100,100)

func _init() -> void:
	tree_entered.connect(_on_tree_entered)

func _ready() -> void:
	print("Node đã sẵn sàng trong Scene Tree!")
	
func _process(delta: float) -> void:
	icon.position = icon_pos

func _on_tree_entered() -> void:
	await get_tree().create_timer(2).timeout
	icon.self_modulate = Color.PURPLE
	pass
