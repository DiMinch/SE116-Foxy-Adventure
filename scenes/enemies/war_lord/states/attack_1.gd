extends EnemyState

@export var attack_range: float = 400.0       # khoảng đạn lăn rồi biến mất
@export var cannon_speed: float = 400.0       # tốc độ bắn ban đầu

var anim: AnimatedSprite2D
var _factory:  Node2DFactory
var cannon : RigidBody2D

func _update(_delta: float) -> void:
	obj.velocity.x=0
	if not anim.animation_finished.is_connected(_on_anim_done):
		anim.animation_finished.connect(_on_anim_done)
func _on_anim_done():
	change_state(fsm.states.idle)
func _enter() -> void:
	# đứng yên khi bắn
	obj.change_animation("atk1")
	anim = obj.get_node("Direction/AnimatedSprite2D") as AnimatedSprite2D
	await get_tree().create_timer(0.2).timeout
	_shoot_cannon()
	
	AudioManager.play_sound("war_lord_attack1")

func _shoot_cannon() -> void:
	_factory = obj.get_node("Direction/Node2DFactory")
	cannon = _factory.create() as RigidBody2D
	cannon.setup(obj.direction, attack_range, cannon_speed, obj.attack_damage)
	
	
