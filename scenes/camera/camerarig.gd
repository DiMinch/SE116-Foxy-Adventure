extends CharacterBody2D

const MapScene = "Stage"
const strPlayer = "Player"
var player: Player

# --- cấu hình follow ---
@export var follow_speed: float = 10.0
@export var offset: Vector2 = Vector2(0, 0) # nâng camera lên trên player chút

@onready var cam: Camera2D = $Camera2D

@export var count_connect := 0

# =========================
# OFFSET ZONE MANAGEMENT
# =========================
var pos_raise_col:Vector2
var _default_offset: Vector2
var _default_offset_inited := false
var _active_zones := {}  # zone_id -> true

func set_camera_offset(pos_raise_collision: Vector2,new_offset: Vector2, zone_id: int = -1) -> void:
	pos_raise_col=pos_raise_collision
	if zone_id != -1:
		if _active_zones.has(zone_id):
			return
		_active_zones[zone_id] = true


	if not _default_offset_inited:
		_default_offset = offset
		_default_offset_inited = true

	offset = new_offset

func reset_camera_offset(zone_id: int = -1) -> void:
	if zone_id != -1:
		_active_zones.erase(zone_id)

	if _default_offset_inited and count_connect <= 0:
		count_connect = 0
		offset = _default_offset
	#shake_ground(0.2,20)

# =========================
# CAMERA SHAKE (GROUND SHAKE)
# =========================
@export var shake_duration := 0.2
@export var shake_strength := 6.0

var _shake_time := 0.0
var _shake_offset := Vector2.ZERO

func shake_ground(duration: float = shake_duration, strength: float = shake_strength) -> void:
	_shake_time = duration
	shake_strength = strength


# =========================
# READY
# =========================
func _ready() -> void:
	count_connect = 0

	if cam:
		cam.enabled = true

	var stage := find_parent(MapScene)
	if stage != null:
		player = stage.find_child(strPlayer) as Player
		if player != null and is_instance_valid(player):
			global_position = player.global_position + offset


# =========================
# PHYSICS PROCESS
# =========================
func _physics_process(delta: float) -> void:
	
	
	var stage := find_parent(MapScene)
	if stage == null:
		return
	player = stage.find_child(strPlayer) as Player
	if player == null or not is_instance_valid(player):
		return
		
	if abs(player.global_position.x-global_position.x)>225 or abs(player.global_position.y-global_position.y)>125:
		
		global_position =player.global_position
	# --- camera shake update ---
	if _shake_time > 0.0:
		_shake_time -= delta
		_shake_offset = Vector2(
			randf_range(-shake_strength, shake_strength),
			randf_range(-shake_strength, shake_strength)
		)
	else:
		_shake_offset = Vector2.ZERO

	# --- follow logic ---
	var desired := player.global_position +offset + _shake_offset# +Vector2(0,100)
	if player.direction==1:
		desired+=Vector2(50,0)
	else :
		desired+=Vector2(-50,0)
	var dir := desired - global_position

	velocity = dir * follow_speed
	move_and_slide()
