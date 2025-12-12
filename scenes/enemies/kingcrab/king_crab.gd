extends EnemyCharacter
@onready var start_detect_player=false
@onready var is_being_hurt=false
@onready var bullet_factory := $Direction/Node2DFactory
@onready var is_atk1=true

@onready var hp_bar = $EnemyHpBarBoss
func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	enemy_type = "KingCrab"
	super._ready()
