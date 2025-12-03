extends RigidBody2D

@export var upward_speed: float = 350.0          # lực hất lên cơ bản
# 3 tham số để điều chỉnh tầm xa
@export var full_range: float = 600.0            # khoảng cách ngang mà tại đó sẽ dùng buff tối đa
@export var max_extra_speed: float = 300.0       # tốc độ cộng thêm tối đa (so với speed gốc)
@export var max_extra_upward: float = 200.0      # lực hất lên cộng thêm tối đa

const MapScene = "Stage"
const strPlayer = "Player"

var attack_damage: int = 0
var player: Player

func _ready() -> void:
	player = find_parent(MapScene).find_child(strPlayer)
	contact_monitor = true
	max_contacts_reported = 4
	body_entered.connect(_on_body_entered)

# direction: tao chỉ lấy hướng ngang (trái / phải)
# speed: Attack_Speed
func start_throw(direction: Vector2, speed: float, damage: int) -> void:
	attack_damage = damage
	# nếu không tìm được player thì bắn kiểu cũ (ngang + hất lên)
	if player == null or not is_instance_valid(player):
		var dir_x := 1.0 if direction.x >= 0.0 else -1.0
		var vx_fallback: float = dir_x * speed
		var vy_fallback: float = -upward_speed
		linear_velocity = Vector2(vx_fallback, vy_fallback)
		return
	var pos: Vector2 = global_position
	
	# vector từ quả dừa -> player
	var to_player: Vector2 = player.global_position - pos
	var distance_x: float = abs(to_player.x)   # chỉ quan tâm khoảng cách ngang để scale
	var distance_total: float = to_player.length()
	
	if distance_total == 0.0:
		# đứng trùng chỗ thì cứ bắn thẳng lên
		linear_velocity = Vector2(0.0, -upward_speed)
		return
	
	# hướng bay (độ dài = 1)
	var dir: Vector2 = to_player.normalized()
	# ----- SCALE THEO KHOẢNG CÁCH NGANG CHO ĐỠ ĐIÊN -----
	# distance_x >= full_range -> dùng buff tối đa
	var ratio: float = clamp(distance_x / full_range, 0.0, 1.0)
	# tốc độ cuối cùng: speed gốc + thêm chút theo khoảng cách (nhưng có giới hạn max_extra_speed)
	var final_speed: float = speed + max_extra_speed * ratio
	# lực hất lên: upward_speed gốc + thêm chút theo khoảng cách
	var final_upward: float = upward_speed + max_extra_upward * ratio
	# vận tốc theo hướng player
	var vx: float = dir.x * final_speed
	var vy: float = dir.y * final_speed - final_upward   # hất lên để cong
	linear_velocity = Vector2(vx, vy)   # Godot tự cộng gravity để thành parabol

func _on_body_entered(body: Node) -> void:
	# chạm player => trừ máu + biến mất
	if body.is_in_group("player"):
		if body.has_method("take_damage"):
			body.take_damage(attack_damage)
		queue_free()

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	queue_free()
