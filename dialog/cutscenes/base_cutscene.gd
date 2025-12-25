extends Control
class_name BaseCutscene

signal cutscene_finished

@export_group("Dialogic Settings")
@export var timeline_name: String = ""

@onready var anim_player = $AnimationPlayer
@onready var texture_rect = $TextureRect
@onready var skip_button = $UI/SkipButton
@onready var fade_layer = $FadeLayer

var current_tween: Tween

func _ready():
	anchors_preset = Control.PRESET_FULL_RECT
	mouse_filter = Control.MOUSE_FILTER_STOP
	
	skip_button.visible = true
	skip_button.disabled = false
	skip_button.mouse_filter = Control.MOUSE_FILTER_STOP
	#skip_button.pressed.connect(_on_skip_button_pressed)
	
	Dialogic.process_mode = Node.PROCESS_MODE_ALWAYS
	Dialogic.signal_event.connect(_on_dialogic_signal)
	
	texture_rect.pivot_offset = size / 2
	
	if anim_player.has_animation("RESET"):
		anim_player.play("RESET")
		
	if timeline_name != "":
		Dialogic.start(timeline_name)
	else:
		push_error("[BaseCutscene] Chưa nhập tên Timeline trong Inspector!")

func _on_skip_button_pressed():
	print("Skipping cutscene...")
	_finish_cutscene()

func _finish_cutscene():
	if current_tween:
		current_tween.kill()
	
	Dialogic.process_mode = Node.PROCESS_MODE_INHERIT
	Dialogic.end_timeline()
	
	if Dialogic.signal_event.is_connected(_on_dialogic_signal):
		Dialogic.signal_event.disconnect(_on_dialogic_signal)
		
	cutscene_finished.emit()
	queue_free()

func _on_dialogic_signal(argument: String):
	var parts = argument.split(":")
	var command = parts[0]
	var param = ""
	if parts.size() > 1:
		param = parts[1]

	match command:
		"fade_in":
			if fade_layer: 
				fade_layer.visible = true
				fade_layer.modulate = Color.BLACK 
			anim_player.play("fade_in")
			
		"fade_out":
			if fade_layer: 
				fade_layer.visible = true
				fade_layer.modulate = Color.BLACK
			anim_player.play("fade_out")
			
		"zoom_in":
			_tween_property(texture_rect, "scale", Vector2(1.3, 1.3), 10.0)
		"pan_right":
			_tween_property(texture_rect, "position", Vector2(-50, 0), 10.0)
		"reset_view":
			_reset_image_transform()
			
		"shake":
			var intensity = 10.0
			if param != "": intensity = float(param)
			_shake_screen(intensity)
			
		"flash":
			_flash_screen()

		"tint":
			var color_hex = "#ffffff"
			var duration = 1.0
			if parts.size() > 1: color_hex = parts[1]
			if parts.size() > 2: duration = float(parts[2])
			
			_tween_property(texture_rect, "modulate", Color(color_hex), duration)
		"effect":
			var type = "normal"
			if parts.size() > 1: type = parts[1]
			_apply_filter_effect(type)
		"vignette_on":
			$VignetteLayer.visible = true
			var t = create_tween()
			t.tween_property($VignetteLayer, "modulate:a", 0.7, 1.0).from(0.0)
		"end_cutscene":
			_finish_cutscene()
		_:
			_handle_custom_signal(argument)

func _handle_custom_signal(_argument: String):
	pass

func _reset_image_transform():
	if current_tween:
		current_tween.kill()
	var t = create_tween().set_parallel(true)
	t.tween_property(texture_rect, "scale", Vector2.ONE, 0.5)
	t.tween_property(texture_rect, "position", Vector2.ZERO, 0.5)
	t.tween_property(texture_rect, "modulate", Color.WHITE, 0.5)

func _start_tween_property(property: String, final_value, duration: float):
	_tween_property(texture_rect, property, final_value, duration)
	
func _tween_property(target: Node, property: String, final_val, duration: float):
	if current_tween: current_tween.kill()
	current_tween = create_tween().set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	current_tween.tween_property(target, property, final_val, duration)

func _shake_screen(intensity: float = 10.0, duration: float = 0.5):
	var shake_tween = create_tween()
	var original_pos = texture_rect.position
	
	for i in range(10):
		var offset = Vector2(randf_range(-intensity, intensity), randf_range(-intensity, intensity))
		shake_tween.tween_property(texture_rect, "position", original_pos + offset, duration / 10)
	
	shake_tween.tween_property(texture_rect, "position", original_pos, 0.0)

func _flash_screen():
	if fade_layer:
		fade_layer.visible = true
		fade_layer.color = Color.WHITE
		fade_layer.modulate = Color(1, 1, 1, 1) 
		
		var t = create_tween()
		t.tween_property(fade_layer, "modulate:a", 0.0, 0.5)
		
		t.tween_callback(func(): 
			fade_layer.visible = false
			fade_layer.modulate = Color.BLACK 
		)

func _apply_filter_effect(type: String):
	var mat = texture_rect.material as ShaderMaterial
	if not mat: return
	
	var tween = create_tween().set_parallel(true)
	
	match type:
		"sepia":
			# Chuyển dần sang Sepia trong 2 giây
			tween.tween_property(mat, "shader_parameter/sepia_amount", 1.0, 2.0)
			tween.tween_property(mat, "shader_parameter/grayscale_amount", 0.0, 2.0)
		"bw": 
			# Chuyển dần sang Trắng đen
			tween.tween_property(mat, "shader_parameter/grayscale_amount", 1.0, 2.0)
			tween.tween_property(mat, "shader_parameter/sepia_amount", 0.0, 2.0)
		"normal":
			# Trả về màu gốc
			tween.tween_property(mat, "shader_parameter/grayscale_amount", 0.0, 1.0)
			tween.tween_property(mat, "shader_parameter/sepia_amount", 0.0, 1.0)
