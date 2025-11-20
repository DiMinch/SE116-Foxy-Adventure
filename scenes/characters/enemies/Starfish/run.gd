extends "res://scenes/characters/enemies/states/run.gd"
func _update(_delta):
	super._update(_delta)
	if obj.found_player:
		if obj.found_player.global_position.x>obj.global_position.x:
			obj.turn_right()
		else :
			obj.turn_left()
		change_state(fsm.states.attack)
	
	if  obj.is_found_player_in_left():
		change_state(fsm.states.attack)

	if obj.is_found_player_in_right():
		obj.turn_around()
		change_state(fsm.states.attack)
