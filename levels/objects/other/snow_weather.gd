extends Node2D

@onready var particles = $CPUParticles2D
@onready var timer = $Timer

@export_group("Timing Settings")
@export var min_wait_time: float = 10.0 # Thời gian tạnh tuyết tối thiểu
@export var max_wait_time: float = 30.0 # Thời gian tạnh tuyết tối đa
@export var min_duration: float = 15.0  # Thời gian tuyết rơi tối thiểu
@export var max_duration: float = 40.0  # Thời gian tuyết rơi tối đa

@export_group("Visual Settings")
@export var fade_duration: float = 2.0 # Thời gian để tuyết hiện dần/tắt dần

var is_snowing: bool = false

func _ready():
	# Mặc định tắt tuyết khi bắt đầu
	particles.emitting = true # Cần true để modulate hoạt động, ta kiểm soát bằng alpha
	particles.modulate.a = 0.0
	is_snowing = false
	
	# Bắt đầu bộ đếm để chờ lần tuyết rơi đầu tiên
	_start_wait_timer()

func _start_wait_timer():
	var wait_time = randf_range(min_wait_time, max_wait_time)
	print("SnowSystem: Trời tạnh. Đợt tuyết tiếp theo trong %.1f giây." % wait_time)
	timer.start(wait_time)

func _start_snow_duration_timer():
	var duration = randf_range(min_duration, max_duration)
	print("SnowSystem: Tuyết bắt đầu rơi! Kéo dài trong %.1f giây." % duration)
	timer.start(duration)

func _on_timer_timeout():
	if is_snowing:
		stop_snow()
	else:
		start_snow()

func start_snow():
	is_snowing = true
	var tween = create_tween()
	# Fade in: Từ trong suốt sang rõ
	tween.tween_property(particles, "modulate:a", 1.0, fade_duration)
	
	# Sau khi bắt đầu rơi, đặt giờ để dừng
	_start_snow_duration_timer()

func stop_snow():
	is_snowing = false
	var tween = create_tween()
	# Fade out: Từ rõ sang trong suốt
	tween.tween_property(particles, "modulate:a", 0.0, fade_duration)
	
	# Sau khi tạnh, đặt giờ để chờ đợt sau
	_start_wait_timer()
