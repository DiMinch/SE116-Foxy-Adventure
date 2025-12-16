extends EnemyCharacter
@onready var sprite = $Direction/AnimatedSprite2D
@onready var hp_bar = $EnemyHpBarMinions
@onready var Hit = $Direction/HitArea2D
@onready var hurt = $Direction/HurtArea2D/CollisionShape2D

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	enemy_type = "Spear"
	super._ready()
