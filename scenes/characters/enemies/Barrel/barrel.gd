extends EnemyCharacter
@export var bullet_speed:float =300
@onready var bullet_factory := $Direction/BulletFactory
@export var default_direction: int = -1 # 1 = bắn sang phải, -1 = bắn sang trái
@export var sight=0
func _ready()->void:
	change_direction(default_direction)
	fsm=FSM.new(self,$States,$States/Idle)
	super._ready()
	self.max_health =EnemyConstants. BARREL_STATS[EnumKeys.EnemyKeys.HEALTH]
	self.gravity=EnemyConstants. BARREL_STATS[EnumKeys.EnemyKeys.GRAVITY]
	self.attack_damage=EnemyConstants. BARREL_STATS[EnumKeys.EnemyKeys.ATTACK_DAMAGE]
	bullet_speed= EnemyConstants. BARREL_STATS[EnumKeys.EnemyKeys.ATTACK_SPEED]
	self.health = self.max_health

func fire()->void:

	var bullet :=bullet_factory.create() as RigidBody2D
	bullet.add_collision_exception_with(self)
	bullet.global_position = bullet_factory.global_position
	var shooting_velocity:=Vector2(bullet_speed*direction,0.0)
	
	bullet.apply_impulse(shooting_velocity)
	
