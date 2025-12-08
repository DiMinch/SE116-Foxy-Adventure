extends HitArea2D
class_name BigShuriken

var stats: ShurikenUlti
var start_pos: Vector2
var direction: int = 1

@onready var sprite = $Direction/Sprite2D 
@onready var collision = $CollisionShape2D

func setup(data: ShurikenUlti, dir: int, pos: Vector2) -> void:
	stats = data
	direction = dir
	global_position = pos
	start_pos = pos
	damage = data.damage_unit

func _ready() -> void:
	super._ready()
	body_entered.connect(_on_body_entered)

	if collision and stats:
		if collision.shape is CircleShape2D:
			collision.shape.radius = stats.aoe_radius
		elif collision.shape is RectangleShape2D:
			var ratio = stats.aoe_radius / 20.0
			collision.scale = Vector2(ratio, ratio)

	if stats:
		var tick_timer = Timer.new()
		tick_timer.wait_time = stats.tick_rate
		tick_timer.autostart = true
		tick_timer.timeout.connect(_on_tick_damage)
		add_child(tick_timer)

func _physics_process(delta: float) -> void:
	if sprite: 
		sprite.rotation += 20.0 * delta

	if stats:
		position.x += stats.speed * direction * delta

	var max_dist = 300.0
	if stats:
		if "fly_range" in stats and stats.fly_range > 0:
			max_dist = stats.fly_range
		elif "range" in stats and stats.range.x > 0:
			max_dist = stats.range.x

	if global_position.distance_to(start_pos) >= max_dist:
		queue_free()

func _on_body_entered(body):
	if body.is_in_group("Enemy"):
		_apply_effect(body)

func _on_tick_damage():
	var targets = get_overlapping_bodies()
	for body in targets:
		if body.is_in_group("Enemy"):
			_apply_effect(body)

func _apply_effect(target):
	if not stats: return
	if target.has_method("take_damage"):
		target.take_damage(stats.damage_unit)
	if target.has_method("apply_knockback"):
		var push_dir = Vector2(direction, 0)
		target.apply_knockback(push_dir, stats.knockback_force, stats.knockback_time)
