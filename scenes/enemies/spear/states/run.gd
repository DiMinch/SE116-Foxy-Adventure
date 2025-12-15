extends EnemyRunState

const MapScene = "Stage"
const strPlayer = "Player"
var player: Player
var Hurt:CollisionShape2D
@export var movement_range: float = 200.0   # phạm vi spear chạy qua (tâm là vị trí lúc vào state)

func _enter()->void:
	Hurt=obj.hurt
func _update(delta: float) -> void:
	# giữ logic chạy / quay đầu gốc (run.gd)
	super._update(delta)
	if is_opposite()==true:
		Hurt.disabled=true
	else : Hurt.disabled=false
	# --- PHẦN ĐUỔI PLAYER GIỮ NGUYÊN ---
	player = find_parent(MapScene).find_child(strPlayer)
	if player and is_instance_valid(player):
		var dx = player.global_position.x - obj.position.x
		var dy = player.global_position.y - obj.position.y
		if abs(dx) <= obj.sight and abs(dy) <= 30:
			if is_opposite() == false:
				obj.turn_around()
			print("[ENEMIES] Spear opposite")
			change_state(fsm.states.idle)

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
	# hướng spear đang nhìn (1 phải, -1 trái)
	var looking_dir: float = obj.direction
	# hướng player nằm (1 phải, -1 trái)
	var player_dir: float = sign(player_x - native_x)
	# true nếu spear nhìn đúng về phía player
	return looking_dir == player_dir
