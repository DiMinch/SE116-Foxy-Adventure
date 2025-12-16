extends BaseCutscene

@export_group("Images")
@export var img1: Texture2D
@export var img2: Texture2D
@export var img3: Texture2D


func _handle_custom_signal(argument: String):
	match argument:
		"image_1":
			_change_texture(img1)
		"image_2":
			_change_texture(img2)
		"image_3":
			_change_texture(img3)

func _change_texture(new_tex: Texture2D):
	_reset_image_transform()
	texture_rect.texture = new_tex
