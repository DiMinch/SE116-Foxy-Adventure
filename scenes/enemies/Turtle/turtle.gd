extends EnemyCharacter
@export var movement_range :float =0.0

func _ready() -> void:
	
	fsm=FSM.new(self, $States,$States/Run)
	super._ready()
	self.max_health =EnemyConstants. TURTLE_STATS[EnumKeys.EnemyKeys.HEALTH]
	self.movement_speed =EnemyConstants. TURTLE_STATS[EnumKeys.EnemyKeys.MOVEMENT_SPEED]
	self.gravity=EnemyConstants. TURTLE_STATS[EnumKeys.EnemyKeys.GRAVITY]
	self.attack_damage=EnemyConstants. TURTLE_STATS[EnumKeys.EnemyKeys.SPIKE]
	movement_range=EnemyConstants. TURTLE_STATS[EnumKeys.EnemyKeys.MOVEMENT_RANGE]
	self.health = self.max_health
