extends EnemyCharacter

func _ready() -> void:
	fsm=FSM.new(self, $States,$States/Run)
	super._ready()


func _on_hit_area_2d_hitted(area: Variant) -> void:
	pass # Replace with function body.
