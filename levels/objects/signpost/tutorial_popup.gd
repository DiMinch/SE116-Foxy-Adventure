extends CanvasLayer

@onready var content_image = $TextureRect/VBoxContainer/ContentImage 
@onready var content_label = $TextureRect/VBoxContainer/Label

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS 
	$TextureRect/Button.pressed.connect(_on_close_button_pressed)
	get_tree().paused = true
	$TextureRect.scale = Vector2.ONE
	$TextureRect.modulate.a = 0.0
	var tween = create_tween()
	tween.tween_property($TextureRect, "modulate:a", 1.0, 0.3)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
		
func setup_content(text_content: String, image_content: Texture2D):
	if content_label:
		content_label.text = text_content
	if content_image:
		if image_content != null:
			content_image.texture = image_content
			content_image.visible = true
		else:
			content_image.visible = false

func _on_close_button_pressed():
	var close_tween = create_tween()
	close_tween.tween_property($TextureRect, "modulate:a", 0.0, 0.2)\
		.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN)
	await close_tween.finished
	get_tree().paused = false
	queue_free()
