extends EnemyState
const MapScene = "Stage"
const strPlayer = "Player"
var is_left: bool = true
var player: Player

func _enter() -> void:
	obj.change_animation("idle")
var dem :int =1

func set_ready_atk():
	await get_tree().create_timer(0.2).timeout
	obj.is_being_hurt =false
	
func _update(_delta: float) -> void:
	if obj.is_being_hurt==true:
		set_ready_atk()
		
	obj.velocity.x=0
	var stage := find_parent(MapScene)
	if stage == null:
		return
	player = stage.find_child(strPlayer) as Player
	if player == null or not is_instance_valid(player):
		return
	var pos: Vector2 = obj.global_position
	# vector  -> player
	var to_player: Vector2 = player.global_position - pos
	# xác định player bên trái / phải (nếu mày còn cần dùng is_left)
	is_left = to_player.x < 0.0
	# KHOẢNG CÁCH CHUẨN: chỉ cần abs(to_player.x), abs(to_player.y)
	var dx: float = abs(to_player.x)
	var dy: float = abs(to_player.y)
	# player nằm trong “hộp” 200 x 150 quanh native thì cho attack
	if dx <= obj.sight and dy <=40 and obj.is_being_hurt==false:
		
		#print(">>> CHANGE TO ATTACK, dx=", dx, " dy=", dy)  # debug xem có chạy vào không
		if is_opposite()==false and obj.is_in_attack_range==false:
			obj.turn_around()
		if obj.is_atk1:
			if dem==1:
				dem+=1
				change_state(fsm.states.attack1)
			else:
				dem=1
				obj.turn_around()
				obj.is_atk1=false
				change_state(fsm.states.attack1)	
		else :
			if dem==1:
				dem+=1
				change_state(fsm.states.attack2)
			else:
				dem=1
				obj.turn_around()
				obj.is_atk1=true
				change_state(fsm.states.attack2)
		obj.is_in_attack_range =true
	else: obj.is_in_attack_range=false


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
