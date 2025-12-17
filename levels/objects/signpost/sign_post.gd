extends Node2D

@export_group("Visual Settings")
@export var sign_texture: Texture2D

@export_group("Interaction Settings")
@export var is_interactable: bool = true
@export var allow_auto_interact: bool = true
@export var popup_scene: PackedScene
@export_multiline var tutorial_text: String = "Nội dung hướng dẫn..."
@export var tutorial_image: Texture2D

@onready var interact_label = $Label
@onready var sprite_2d = $Sprite2D
@onready var interactive_area = $InteractiveArea2D

var has_auto_triggered: bool = false

func _ready():
	# 1. Cập nhật Skin (nếu có assign ảnh)
	if sign_texture != null:
		sprite_2d.texture = sign_texture
	
	# 2. Xử lý logic tương tác
	if not is_interactable:
		# Nếu không cho tương tác, tắt vùng va chạm và label
		interactive_area.queue_free()
		interact_label.visible = false
		return

	# Nếu cho tương tác thì mới kết nối tín hiệu
	if popup_scene == null:
		# Fallback
		popup_scene = load("res://levels/objects/signpost/tutorial_popup.tscn")

	interactive_area.interaction_available.connect(_on_interaction_available)
	interactive_area.interaction_unavailable.connect(_on_interaction_unavailable)
	interactive_area.interacted.connect(_on_interacted)

func _on_interaction_available():
	interact_label.visible = true
	
	if not has_auto_triggered and is_interactable and allow_auto_interact:
		has_auto_triggered = true
		_on_interacted()

func _on_interaction_unavailable():
	interact_label.visible = false

func _on_interacted():
	if not is_interactable or popup_scene == null:
		return

	var popup = popup_scene.instantiate()
	
	# Thêm vào scene root (để nó nổi lên trên cùng)
	get_tree().root.add_child(popup)
	
	if popup.has_method("setup_content"):
		popup.setup_content(tutorial_text, tutorial_image)
