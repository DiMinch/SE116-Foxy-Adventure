extends HitArea2D
class_name AtomicBoomerang

enum State { FLY_OUT, RETURN }
var current_state = State.FLY_OUT

var stats: BoomerangUlti
var start_pos: Vector2
var direction: int = 1
var player_target: Player

@onready var sprite = $Direction/Sprite2D

func setup(data: BoomerangUlti, dir: int, pos: Vector2, owner_player: Player):
	stats = data
	direction = dir
	start_pos = pos
	global_position = pos
	player_target = owner_player

func _physics_process(delta: float) -> void:
	if sprite: sprite.rotation += 25.0 * direction * delta

	match current_state:
		State.FLY_OUT:
			position.x += stats.fly_speed * direction * delta

			if global_position.distance_to(start_pos) >= stats.fly_distance:
				current_state = State.RETURN
		
		State.RETURN:
			if is_instance_valid(player_target):
				var dir_to_player = (player_target.global_position - global_position).normalized()
				position += dir_to_player * stats.return_accel * delta

				if global_position.distance_to(player_target.global_position) < 20:
					queue_free()
			else:
				queue_free()

func hit(hurt_area):
	var grand_parent = hurt_area.get_parent().get_parent()
	if grand_parent is Grass:
		return
	if hurt_area.has_method("take_damage"):

		var current_hp = 0
		current_hp = grand_parent.health

		var dynamic_damage = int(current_hp * stats.enemy_hp_percent)
		
		if dynamic_damage < 1: dynamic_damage = 1
		var hit_dir: Vector2 = hurt_area.global_position - global_position
		hurt_area.take_damage(hit_dir.normalized(), dynamic_damage)
		hitted.emit(hurt_area)
		
		print("Atomic Boomerang hit: ", dynamic_damage)

func _on_body_entered(body):
	if body is TileMap or body is StaticBody2D:
		current_state = State.RETURN
		return
	hit(body)
