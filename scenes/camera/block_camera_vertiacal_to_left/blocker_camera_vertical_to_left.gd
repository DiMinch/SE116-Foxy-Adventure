extends StaticBody2D

const MapScene = "Stage"
const strPlayer = "Player"
var is_left: bool = true
var player: Player
@onready var Coll=$CollisionShape2D
@onready var shape := $CollisionShape2D.shape as RectangleShape2D
func _process(delta: float) -> void:
	var stage := find_parent(MapScene)
	if stage == null:
		return
	player = stage.find_child(strPlayer) as Player
	if player == null or not is_instance_valid(player):
		return
	if global_position.x>player.global_position.x:
		Coll.disabled=true
	else :
		Coll.disabled=false
		
