extends EnemyState

@export var atk_range: float =200
@export var pincers_speed:float=200
var pincers_factory: Node2DFactory

const MapScene = "Stage"
const strPlayer = "Player"
var pincers : RigidBody2D
func _enter() -> void:
	obj.velocity = Vector2.ZERO
	obj.change_animation("attack2")

	if not is_opposite():
		obj.turn_around()

	pincers_factory = obj.get_node("Direction/Node2DFactory")

	# TẠO PINCERS RỒI QUÊN NÓ LUÔN
	pincers = pincers_factory.create() as RigidBody2D
	var start_pos := obj.global_position
	var target_pos := start_pos + Vector2(atk_range * obj.direction, 0.0)

	pincers.global_position = start_pos
	
	pincers.setup(start_pos, target_pos, obj, pincers_speed)

	# Chỉ xử lý animation + đổi state bằng coroutine riêng
	_do_attack_sequence()
	
func _do_attack_sequence() -> void:
	# Chờ 0.2s rồi đổi anim (cua)
	await get_tree().create_timer(0.7).timeout
	obj.change_animation("returnpincers")
	
func _update(_delta: float) -> void:
	if pincers == null or not is_instance_valid(pincers):
		change_state(fsm.states.dizzy)
	# Attack2 không làm gì mỗi frame nữa
	pass

func is_opposite() -> bool:
	var stage := obj.find_parent(MapScene)
	if stage == null:
		return false

	var p := stage.find_child(strPlayer) as Player
	if p == null or not is_instance_valid(p):
		return false

	var kingcrab_x: float = obj.global_position.x
	var player_x: float = p.global_position.x
	var looking_dir: float = obj.direction
	var player_dir: float = sign(player_x - kingcrab_x)
	return looking_dir == player_dir
