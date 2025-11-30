extends EnemyCharacter

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	enemy_type = "Spear"
	super._ready()
