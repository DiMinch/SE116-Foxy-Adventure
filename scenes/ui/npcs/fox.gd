extends Node2D
class_name Fox

@export var fox_name: String = ""
@export var popup_scene: PackedScene
@export_enum("left", "right") var direction = "left"

@onready var interactive_area = $InteractiveArea2D
@onready var interact_label = $Label
@onready var animated_sprite = $AnimatedSprite2D

func _ready() -> void:
	$NameLabel.text = fox_name
	animated_sprite.play("default")
	animated_sprite.flip_h = false if direction == "left" else true
	
	interactive_area.interaction_available.connect(_on_interaction_available)
	interactive_area.interaction_unavailable.connect(_on_interaction_unavailable)
	interactive_area.interacted.connect(_on_interacted)

func _on_interaction_available():
	interact_label.visible = true

func _on_interaction_unavailable():
	interact_label.visible = false

func _on_interacted():
	var popup = popup_scene.instantiate()
	var main_ui = get_parent().get_parent().get_node_or_null("MainLayer")
	if main_ui:
		main_ui.add_child(popup)
	else:
		get_tree().root.add_child(popup)
