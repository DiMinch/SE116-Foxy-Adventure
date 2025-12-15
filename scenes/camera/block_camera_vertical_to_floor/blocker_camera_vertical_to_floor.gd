extends StaticBody2D

const MapScene = "Stage"
const strPlayer = "Player"
var is_left: bool = true
var player: Player
@onready var is_out_of_zone=true
@onready var Coll=$CollisionShape2D
@onready var shape := $CollisionShape2D.shape as RectangleShape2D
func _process(delta: float) -> void:
	var width: float = shape.size.x
	var height: float = shape.size.y

	var stage := find_parent(MapScene)
	if stage == null:
		return
	player = stage.find_child(strPlayer) as Player
	
	var d=player.global_position.x-global_position.x
	if d>width/2: #and player.is_on_floor()==false:
		is_out_of_zone=true	
	else :
		is_out_of_zone=false
	if player == null or not is_instance_valid(player):
		return
	if global_position.y<player.global_position.y and is_out_of_zone==false:
		Coll.disabled=true
	else :
		Coll.disabled=false
		
	
