extends EnemyCharacter
@onready var hp_bar = $EnemyHpBarMinions
@onready var coconut_factory := $Direction/Node2DFactory
@onready var sprite = $Direction/AnimatedSprite2D
@onready var Hit =$Direction/HitArea2D

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	enemy_type = "Native"
	super._ready()
