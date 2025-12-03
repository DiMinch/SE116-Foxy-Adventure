extends EnemyCharacter

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	enemy_type = "Turtle"
	super._ready()
