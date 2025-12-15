extends StaticBody2D

const MapScene = "Stage"
const strPlayer = "Player"
var is_left: bool = true
var player: Player
@onready var Coll=$CollisionShape2D
@onready var shape := $CollisionShape2D.shape as RectangleShape2D
@onready var is_out_of_zone=true
func _process(delta: float) -> void:
	var width: float = shape.size.x*Coll.scale.x*scale.x
	var height: float = shape.size.y*Coll.scale.y*scale.y
	
	var stage := find_parent(MapScene)
	if stage == null:
		return
	player = stage.find_child(strPlayer) as Player
	
	var d=player.global_position.y-global_position.y
	if d>abs(height/2): 
		is_out_of_zone=true	
	else :
		is_out_of_zone=false
	if player == null or not is_instance_valid(player):
		return
	if global_position.x>player.global_position.x+100 and is_out_of_zone==false:
		Coll.disabled=false
	elif global_position.x<player.global_position.x or is_out_of_zone==true:
		Coll.disabled=true
	
	if is_win():
		queue_free()
	
	if is_in() and is_out_of_zone ==false:
		if player.global_position.x>global_position.x-75:
			player.global_position.x = global_position.x-75
const strKingCrab = "KingCrab"
var C_K: EnemyCharacter
func is_win():
	var stage := find_parent(MapScene)
	if stage == null:
		return
	C_K = stage.find_child(strKingCrab) as EnemyCharacter
	if C_K == null or not is_instance_valid(C_K):
		return true
	else : return false
	
const strfixLeft = "FixedCameraLeftKingCrab"
var left: StaticBody2D
func is_in():
	var stage := find_parent(MapScene)
	if stage == null:
		return false
	left = stage.find_child(strfixLeft) as StaticBody2D
	if left == null or not is_instance_valid(left):
		return false
	if player.global_position.x <global_position.x and player.global_position.x>left.global_position.x:
		return true
	else: return false
