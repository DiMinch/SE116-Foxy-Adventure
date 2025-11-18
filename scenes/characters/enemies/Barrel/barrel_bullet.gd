extends RigidBody2D

@export var movement_range: float = 300.0  # khoảng bay tối đa (tuỳ chỉnh trong Inspector)

var _start_pos: Vector2   # lưu vị trí bắt đầu

func _ready() -> void:
	contact_monitor = true
	max_contacts_reported = 4
	movement_range =EnemyConstants. BARREL_STATS[EnumKeys.EnemyKeys.MOVEMENT_RANGE]
	_start_pos = global_position  # ghi lại vị trí lúc mới sinh ra

	connect("body_entered", Callable(self, "_on_body_entered"))


func _physics_process(delta: float) -> void:
	# Nếu bay xa hơn moment_range thì tự huỷ
	if abs(global_position.x - _start_pos.x) >= movement_range:
		queue_free()


func _on_hit_area_2d_hitted(_area: Variant) -> void:
	queue_free()
	
func _on_body_entered(_body: Node) -> void:
	queue_free()
