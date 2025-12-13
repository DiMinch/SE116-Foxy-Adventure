extends EnemyCharacter
@onready var hp_bar = $EnemyHpBarMinions
@onready var bullet_factory := $Direction/BulletFactory
@export var default_direction: int = -1 # 1 = bắn sang phải, -1 = bắn sang trái
@onready var sprite = $Direction/AnimatedSprite2D
func _ready() -> void:
	change_direction(default_direction)
	fsm = FSM.new(self, $States, $States/Idle)
	enemy_type = "Barrel"
	super._ready()

func fire() -> void:
	# Create bullet
	var bullet := bullet_factory.create() as RigidBody2D
	# Set stat
	bullet.find_child("HitArea2D").damage = attack_damage
	bullet.movement_range = movement_range
	# Set collision
	bullet.add_collision_exception_with(self)
	bullet.global_position = bullet_factory.global_position
	var shooting_velocity := Vector2(attack_speed * direction, 0.0)
	bullet.apply_impulse(shooting_velocity)
