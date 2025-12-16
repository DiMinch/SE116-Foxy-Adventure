extends EnemyState

@export var speed_moment:float
@export var moment_screen: float = 150.0   # đi bao nhiêu pixel thì dừng

const MapScene = "Stage"
const strPlayer = "Player"
var _anim: AnimatedSprite2D

var start_x: float
func _enter() -> void:
	speed_moment=obj.movement_speed
	# lấy vị trí bắt đầu
	start_x = obj.global_position.x
	#if is_opposite()==false:
		#obj.turn_around()
	obj.change_animation("attack1")
	obj.velocity.x = obj.direction * speed_moment
	
	AudioManager.play_sound("kingcrab_attack1")
	
func _update(delta: float) -> void:
	if _should_turn_around():
		obj.turn_around()
		change_state(fsm.states.run)
	obj.move_and_slide()
	# kiểm tra quãng đường đã đi
	
	var dist = abs(obj.global_position.x - start_x)

	if dist >= moment_screen:
		# dừng lại
		obj.change_animation("stop")
		obj.velocity.x = 0
		_anim = obj.get_node("Direction/AnimatedSprite2D")
		
		if not _anim.animation_finished.is_connected(_on_anim_finished):
			_anim.animation_finished.connect(_on_anim_finished)

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
	
func _on_anim_finished():
	# Quan trọng: kiểm tra đúng animation
	if _anim.animation == "stop":
		change_state(fsm.states.run)
func _should_turn_around()->bool:
	if obj.is_touch_wall():
		return true
	if obj.is_on_floor() and obj.is_can_fall():
		return true
	return false
