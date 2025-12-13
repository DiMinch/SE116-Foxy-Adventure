extends EnemyState

@export var rocket_scene: Node2DFactory    # gán rocket.tscn ở Inspector
@export var d: float = 100                 # khoảng cách từ war_lord tới điểm rơi
	  # độ cao đỉnh quỹ đạo (gửi cho rocket.gd nếu cần)
var _anim: AnimatedSprite2D

func _enter() -> void:
	# đứng yên khi tấn công
	rocket_scene =obj.get_node("Direction/Node2DFactory2")
	# đổi anim tấn công
	obj.change_animation("atk2")
	# lấy AnimatedSprite2D để bắt sự kiện animation_finished
	_anim = obj.get_node("Direction/AnimatedSprite2D") as AnimatedSprite2D
	if _anim:
		var frames := _anim.sprite_frames
		if not _anim.animation_finished.is_connected(_on_attack_finished):
			_anim.animation_finished.connect(_on_attack_finished)
	# bắn rocket đúng 1 lần khi vào state
	await get_tree().create_timer(0.7).timeout
	_shoot_rockets()

func _shoot_rockets() -> void:
	if rocket_scene == null:
		return
	# vị trí bắt đầu bắn
	var origin: Vector2 = obj.global_position
	# bắn 2 hướng: trái (-1) và phải (1)
	for dir in [-1, 1]:
		var rocket := rocket_scene.create() as RigidBody2D
		# spawn ngay tại war_lord
		rocket.global_position = origin 
		# tính điểm rơi: cách war_lord một đoạn d theo trục X
		var target := origin + Vector2((d) * dir, 0.0)
		var target2 := origin + Vector2((d+100) * dir, 0.0)
		# nếu script rocket.gd có hàm setup thì truyền dữ liệu cho nó
		# gợi ý rocket.gd: func setup(start: Vector2, target: Vector2, height: float)
		if rocket.has_method("setup"):
			if obj.is_short==true:
				rocket.call("setup", origin, target,2.5,0.7,0.35,obj.attack_damage)
			else:
				obj.is_take_a_rest=true
				rocket.call("setup", origin, target2,2.5,0.8,0.4,obj.attack_damage)	
				
	if obj.is_short==true:
		obj.is_short=false
	else:
		obj.is_short=true		

func _on_attack_finished() -> void:
	# khi anim attack2 chạy xong thì quay về trạng thái chạy
	if obj.is_take_a_rest==true:
		change_state(fsm.states.takearest)
	else:
		change_state(fsm.states.idle)
func _update(_delta: float) -> void:
	obj.velocity.x=0
