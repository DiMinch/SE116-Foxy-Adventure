extends EnemyCharacter

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	enemy_type = "Starfish"
	super._ready()
