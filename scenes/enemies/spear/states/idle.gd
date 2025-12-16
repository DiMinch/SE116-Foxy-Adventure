extends EnemyState

const MapScene = "Stage"
const strPlayer = "Player"
var Hurt:CollisionShape2D
var player: Player

var _time: float = 0.0

func _enter() -> void:
	Hurt=obj.hurt
	_time = 0.0
	obj.velocity.x = 0
	obj.change_animation("idle")

func _update(delta: float) -> void:
	# đứng yên không di chuyển
	if is_opposite()==true:
		Hurt.disabled=true
	else : Hurt.disabled=false
	obj.velocity.x = 0
	player = find_parent(MapScene).find_child(strPlayer)
	var dx = player.global_position.x - obj.position.x
	var dy = player.global_position.y - obj.position.y
	if abs(dx) > obj.sight or abs(dy) > 100:
		change_state(fsm.states.run)
	# đếm thời gian
	_time += delta
	if _time >= 2:
		# chuyển sang attack
		if is_opposite() == false:
			obj.turn_around()
		change_state(fsm.states.attack)

func is_opposite() -> bool:
	# lấy player
	var stage := obj.find_parent(MapScene)
	if stage == null:
		return false
	
	var p := stage.find_child(strPlayer) as Player
	if p == null or not is_instance_valid(p):
		return false
	
	var native_x: float = obj.global_position.x
	var player_x: float = p.global_position.x
	# hướng native đang nhìn (1 phải, -1 trái)
	var looking_dir: float = obj.direction
	# hướng player nằm (1 phải, -1 trái)
	var player_dir: float = sign(player_x - native_x)
	# true nếu native nhìn đúng về phía player
	return looking_dir == player_dir
