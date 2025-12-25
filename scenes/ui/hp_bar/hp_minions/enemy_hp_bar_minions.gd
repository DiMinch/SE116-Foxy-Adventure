extends Node2D
class_name HPBar_minions

@export var smooth_speed: float = 2.0   # tốc độ tụt mượt

@onready var bar: TextureProgressBar = $Bar

var max_hp: float = 100
var target_hp: float = 1.0     # HP thật từ enemy
var display_hp: float = 1.0    # HP đang hiển thị

# Gọi 1 lần khi spawn enemy
func _ready() -> void:
	target_hp = max_hp
	display_hp = max_hp

	bar.max_value = max_hp
	bar.value = max_hp
	
# Enemy gọi hàm này mỗi khi máu thay đổi
func set_hp(current_hp: float) -> void:
	target_hp = clamp(current_hp, 0.0, max_hp)

func _process(delta: float) -> void:
	if display_hp == target_hp:
		return

	display_hp = move_toward(
		display_hp,
		target_hp,
		smooth_speed * max_hp * delta
	)

	bar.value = display_hp
