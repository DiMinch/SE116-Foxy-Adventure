extends HitArea2D
class_name BigShuriken

# --- Data ---
var stats: ShurikenUlti
var start_pos: Vector2
var direction: int = 1
var stuck: bool = false          # Dừng tại chỗ khi trúng
var did_stuck: bool = false
# --- Nodes ---
@onready var sprite: Sprite2D = $Direction/Sprite2D
@onready var collision: CollisionShape2D = $CollisionShape2D

# --- Setup shuriken ---
func setup(data: ShurikenUlti, dir: int, pos: Vector2) -> void:
	stats = data
	direction = dir
	global_position = pos
	start_pos = pos
	stuck = false
	damage = stats.damage_unit
	# Điều chỉnh collision shape theo AoE
	if collision and stats:
		if collision.shape is CircleShape2D:
			collision.shape.radius = stats.aoe_radius
		elif collision.shape is RectangleShape2D:
			var ratio = stats.aoe_radius / 20.0
			collision.scale = Vector2(ratio, ratio)

	# Timer tick damage liên tục
	if stats:
		var tick_timer = Timer.new()
		tick_timer.wait_time = stats.tick_rate
		tick_timer.autostart = true
		tick_timer.timeout.connect(_on_tick_damage)
		add_child(tick_timer)

# --- Physics update ---
func _physics_process(delta: float) -> void:
	if sprite:
		sprite.rotation += 400.0 * delta  # xoay liên tục

	if stats and not stuck:
		# Bay ban đầu
		position.x += stats.speed * direction * delta

	if !did_stuck && stuck:
		# Bay ban đầu
		did_stuck = true
		var despawn_timer = Timer.new()
		despawn_timer.wait_time = 3
		despawn_timer.one_shot = true
		despawn_timer.autostart = true
		despawn_timer.timeout.connect(queue_free)
		add_child(despawn_timer)
	# Kiểm tra phạm vi tối đa
	var max_dist = stats.fly_range if stats else 300.0
	if global_position.distance_to(start_pos) >= max_dist:
		queue_free()

	# Check va chạm thủ công
	var targets = get_overlapping_bodies()
	for target in targets:
		if target.is_in_group("Enemy"):
			hit(target)

# --- Hit effect ---
func hit(hurt_area):
	if not stats: return

	var enemy_node = hurt_area.get_parent().get_parent()
	if not enemy_node: return
	super(hurt_area)
	if not stuck:
		stuck = true
		global_position.x += direction * 25

# --- Tick damage liên tục ---
func _on_tick_damage():
	if not stats:
		return
	var targets = get_overlapping_areas()
	var d_damage = Vector2.ZERO
	for body in targets:
		if body is HurtArea2D:
			body.take_damage(d_damage, damage)
