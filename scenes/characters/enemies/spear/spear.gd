extends EnemyCharacter
@export var sight: float =100
@export var movement_range :float =200
@export var Attack_Speed: float =50
func _ready() -> void:
	fsm=FSM.new(self, $States,$States/Run)
	super._ready()
	self.max_health =EnemyConstants. SPEAR_STATS[EnumKeys.EnemyKeys.HEALTH]
	self.movement_speed =EnemyConstants. SPEAR_STATS[EnumKeys.EnemyKeys.MOVEMENT_SPEED]
	self.gravity=EnemyConstants. SPEAR_STATS[EnumKeys.EnemyKeys.GRAVITY]
	self.attack_damage=EnemyConstants. SPEAR_STATS[EnumKeys.EnemyKeys.ATTACK_DAMAGE]
	sight=EnemyConstants. SPEAR_STATS[EnumKeys.EnemyKeys.SIGHT]
	Attack_Speed=EnemyConstants. SPEAR_STATS[EnumKeys.EnemyKeys.ATTACK_SPEED]
	movement_range=EnemyConstants. SPEAR_STATS[EnumKeys.EnemyKeys.MOVEMENT_RANGE]
	self.health = self.max_health

	
