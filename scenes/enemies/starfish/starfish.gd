extends EnemyCharacter
@onready var hp_bar = $EnemyHpBarMinions
func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	enemy_type = "Starfish"
	super._ready()
