extends EnemyCharacter

func _ready() -> void:
	fsm=FSM.new(self, $States,$States/Run)
	enemy_type = "Crab"
	super._ready()
