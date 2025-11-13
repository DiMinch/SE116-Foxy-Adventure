extends EnemyCharacter

func _ready() -> void:
	fsm=FSM.new(self, $States,$States/Run)
	super._ready()
	self.max_health =EnemyConstants. CRAB_STATS[EnumKeys.EnemyKeys.HEALTH]
	self.movement_speed =EnemyConstants. CRAB_STATS[EnumKeys.EnemyKeys.MOVEMENT_SPEED]
	self.jump_speed=EnemyConstants. CRAB_STATS[EnumKeys.EnemyKeys.JUMP_SPEED]
	self.gravity=EnemyConstants. CRAB_STATS[EnumKeys.EnemyKeys.GRAVITY]
	self.attack_damage=EnemyConstants. CRAB_STATS[EnumKeys.EnemyKeys.ATTACK_DAMAGE]
	
#	self.spike=EnemyConstants. CRAB_STATS[EnumKeys.EnemyKeys.SPIKE]
#	self.sight=EnemyConstants. CRAB_STATS[EnumKeys.EnemyKeys.SIGHT]
#	self.movement_range=EnemyConstants. CRAB_STATS[EnumKeys.EnemyKeys.MOVEMENT_RANGE]
#	self.attack_speed=EnemyConstants. CRAB_STATS[EnumKeys.EnemyKeys.ATTACK_SPEED]
	self.health = self.max_health
	
func _on_hit_area_2d_hitted(area: Variant) -> void:
	pass # Replace with function body.
