extends Control

signal cutscene_finished

@onready var anim_player = $AnimationPlayer
@onready var texture_rect = $TextureRect
@onready var skip_button = $UI/SkipButton

var img1 = preload("res://assets/cutscenes/opening_1.jpg")
var img2 = preload("res://assets/cutscenes/opening_2.jpg")
var next_level = "res://levels/level1.tscn"
var current_tween: Tween

func _ready():
	skip_button.visible = true
	skip_button.disabled = false
	skip_button.mouse_filter = Control.MOUSE_FILTER_STOP
	
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.signal_event.connect(_on_dialogic_signal)
	texture_rect.pivot_offset = Vector2(240, 135)
	anim_player.play("RESET")
	Dialogic.start("intro_timeline")
	
func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed:
		if skip_button.get_global_rect().has_point(event.position):
			get_tree().root.set_input_as_handled()
			_on_skip_button_pressed()
	
func _on_skip_button_pressed():
	print("Skipping cutscene...")
	_finish_cutscene()
	
func _finish_cutscene():
	## 1. Đánh dấu đã xem
	#GameManager.has_seen_intro = true
	## (Gọi hàm save game ở đây nếu muốn lưu vĩnh viễn)
	## SaveSystem.save_game() 
	
	if current_tween:
		current_tween.kill()
	
	Dialogic.process_mode = Node.PROCESS_MODE_INHERIT
	Dialogic.end_timeline()
	if Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.disconnect(_on_dialogic_signal)
		
	cutscene_finished.emit()
	queue_free()

func _on_dialogic_signal(argument: String):
	print(".")
	match argument:
		"fade_in":
			anim_player.play("fade_in")
			
		"fade_out":
			anim_player.play("fade_out")
			
		"image_1":
			_reset_image_transform()
			texture_rect.texture = img1
			
		"image_2":
			_reset_image_transform()
			texture_rect.texture = img2
		
		"zoom_slow_start":
			_start_tween_property("scale", Vector2(1.2, 1.2), 10.0)
			
		"end_cutscene":
			_finish_cutscene()

func _reset_image_transform():
	if current_tween:
		current_tween.kill()
	texture_rect.scale = Vector2.ONE
	texture_rect.position = Vector2.ZERO

func _start_tween_property(property: String, final_value, duration: float):
	if current_tween:
		current_tween.kill()
		
	current_tween = create_tween()
	current_tween.set_trans(Tween.TRANS_SINE)
	current_tween.set_ease(Tween.EASE_IN_OUT)
	
	current_tween.tween_property(texture_rect, property, final_value, duration)
