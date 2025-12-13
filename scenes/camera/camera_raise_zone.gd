extends Area2D
class_name CameraRaiseZone

@export var raise_offset := Vector2(0, -100)
@export var only_apply_to_group := "camera_rig"
@export var exit_delay := 1

var _inside := {}   # body -> true/false

const MapScene = "Stage"
const strCameraRaiseZone = "Camerarig"
const strPlayer = "Player"
var camera: CharacterBody2D
var player: Player

func _on_area_entered(area: Area2D) -> void:

	_inside[area] = true
	var stage := find_parent(MapScene)
	if stage == null:
		return
	camera = stage.find_child(strCameraRaiseZone) as CharacterBody2D
	if camera == null or not is_instance_valid(camera):
		return
	camera.count_connect+=1
	camera.set_camera_offset(position,raise_offset,get_instance_id())
	
func _on_area_exited(area: Area2D) -> void:

	_inside[area] = false
	var stage := find_parent(MapScene)
	if stage == null:
		return
	camera = stage.find_child(strCameraRaiseZone) as CharacterBody2D
	if camera == null or not is_instance_valid(camera):
		return
	camera.count_connect-=1

	# --- SỬA LOGIC CHỖ NÀY ---
	if is_player_go_away() == false:
		await _wait_exit_delay_or_player_floor(area)
	else:
		camera.reset_camera_offset(get_instance_id())

func _wait_exit_delay_or_player_floor(area: Area2D) -> void:
	# Nếu đang chờ mà area quay lại zone -> hủy reset
	# Nếu đang chờ mà player "go_away" (is_on_floor) -> reset ngay
	var t := 0.0
	var step := 0.05

	while t < exit_delay:
		# nếu area đã vào lại trong lúc chờ -> thôi
		if _inside.get(area, false) == true:
			return

		# nếu player go_away trong lúc chờ -> reset ngay, khỏi chờ nữa
		if is_player_go_away() == true:
			break

		await get_tree().create_timer(step).timeout
		t += step

	# Sau khi hết chờ (hoặc break sớm), chỉ reset nếu area vẫn ở ngoài
	if _inside.get(area, false) == false and is_instance_valid(camera):
		camera.reset_camera_offset(get_instance_id())


func is_player_go_away()->bool:
	var stage := find_parent(MapScene)
	if stage == null:
		return false
	player = stage.find_child(strPlayer) as Player
	if player == null or not is_instance_valid(player):
		return false
	if player.is_on_floor(): 
		return true
	if player.global_position.y>global_position.y:
		return true
	return false
