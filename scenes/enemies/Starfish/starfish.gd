extends EnemyCharacter
func _ready()->void:
	fsm=FSM.new(self,$States,$States/Run)
	super._ready()
func on_body_entered(body):
	pass
