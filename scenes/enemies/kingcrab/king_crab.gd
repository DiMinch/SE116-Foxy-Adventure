extends EnemyCharacter
@onready var bullet_factory := $Direction/Node2DFactory
@onready var is_atk1=true
func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	enemy_type = "KingCrab"
	super._ready()
