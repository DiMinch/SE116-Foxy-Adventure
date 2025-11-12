extends PlayerState
func _enter()->void:
	obj.change_animation("attack")
	timer = 0.2
	obj.velocity.x=0
	if obj.has_blade==true:
		obj.get_node("Direction/HitArea2d/CollisionShape2D").disabled=false
func _exit()->void:
	obj.get_node("Direction/HitArea2d/CollisionShape2D").disabled=true
func _update(delta:float)->void:
	if update_timer(delta):
		change_state(fsm.previous_state)
