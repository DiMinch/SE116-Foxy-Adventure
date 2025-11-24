extends EnemyCharacter

func _ready()->void:
	fsm=FSM.new(self,$States,$States/Run)
	super._ready()
	self.max_health =EnemyConstants. STARFISH_STATS[EnumKeys.EnemyKeys.HEALTH]
	self.movement_speed =EnemyConstants. STARFISH_STATS[EnumKeys.EnemyKeys.MOVEMENT_SPEED]
	self.jump_speed=EnemyConstants. STARFISH_STATS[EnumKeys.EnemyKeys.JUMP_SPEED]
	self.gravity=EnemyConstants. STARFISH_STATS[EnumKeys.EnemyKeys.GRAVITY]
	self.attack_damage=EnemyConstants. STARFISH_STATS[EnumKeys.EnemyKeys.ATTACK_DAMAGE]
	
#	self.spike=EnemyConstants. STARFISH_STATS[EnumKeys.EnemyKeys.SPIKE]
#	self.sight=EnemyConstants. STARFISH_STATS[EnumKeys.EnemyKeys.SIGHT]
#	self.movement_range=EnemyConstants. STARFISH_STATS[EnumKeys.EnemyKeys.MOVEMENT_RANGE]
#	self.attack_speed=EnemyConstants. STARFISH_STATS[EnumKeys.EnemyKeys.ATTACK_SPEED]
	self.health = self.max_health
func on_body_entered(body):
	pass
