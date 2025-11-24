extends EnemyCharacter

@export var Movement_range = 100
@export var Attack_Speed = 200
#@export var Attack_Damage = 50
@export var sight=0
@onready var coconut_factory := $Direction/Node2DFactory

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	super._ready()
	self.max_health =EnemyConstants. NATIVE_STATS[EnumKeys.EnemyKeys.HEALTH]
	self.movement_speed =EnemyConstants. NATIVE_STATS[EnumKeys.EnemyKeys.MOVEMENT_SPEED]
	self.gravity=EnemyConstants. NATIVE_STATS[EnumKeys.EnemyKeys.GRAVITY]
	self.attack_damage=EnemyConstants. NATIVE_STATS[EnumKeys.EnemyKeys.ATTACK_DAMAGE]
	Attack_Speed=EnemyConstants. NATIVE_STATS[EnumKeys.EnemyKeys.ATTACK_SPEED]
	Movement_range =EnemyConstants. NATIVE_STATS[EnumKeys.EnemyKeys.MOVEMENT_RANGE]
	sight=EnemyConstants. NATIVE_STATS[EnumKeys.EnemyKeys.SIGHT]
	self.health = self.max_health
