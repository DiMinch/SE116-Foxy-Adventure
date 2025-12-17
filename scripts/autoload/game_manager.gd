extends Node

#target portal name is the name of the portal to which the player will be teleported
var target_portal_name: String = ""
# Checkpoint system variables
var current_checkpoint_id: String = ""
var checkpoint_data: Dictionary = {}

var current_stage: Node = null
var player: Player = null
var inventory_system: InvetorySystem = null

func _ready() -> void:
	# Load checkpoint data when game starts
	load_checkpoint_data()
	# Add inventory system
	inventory_system = InvetorySystem.new()
	add_child(inventory_system)

func clear_level_coins():
	if inventory_system:
		inventory_system.reset_level_coins()

#change stage by path and target portal name
func change_stage(stage_path: String, _target_portal_name: String = "") -> void:
	target_portal_name = _target_portal_name
	#change scene to stage path
	get_tree().change_scene_to_file(stage_path)

#call from dialogic
func call_from_dialogic(msg: String = ""):
	#Dialogic.VAR["PlayerScore"] = 30
	print("Call from dialogic " + msg)

#respawn at portal or door
func respawn_at_portal() -> bool:
	if not target_portal_name.is_empty():
		player.global_position = current_stage.find_child(target_portal_name).global_position
		GameManager.target_portal_name = ""
		return true
	return false

# Checkpoint system functions
func save_checkpoint(checkpoint_id: String) -> void:
	current_checkpoint_id = checkpoint_id
	var player_state_dict: Dictionary = player.save_state()
	checkpoint_data[checkpoint_id] = {
		"player_state": player_state_dict,
		"stage_path": current_stage.scene_file_path,
		"health": player.health,
	}
	print("Checkpoint saved: ", checkpoint_id)

func load_checkpoint(checkpoint_id: String) -> Dictionary:
	if checkpoint_id in checkpoint_data:
		return checkpoint_data[checkpoint_id]
	return {}

#respawn at checkpoint
func respawn_at_checkpoint() -> bool:
	if current_checkpoint_id.is_empty():
		print("No checkpoint available")
		return false
	
	var checkpoint_info = checkpoint_data.get(current_checkpoint_id, {})
	if checkpoint_info.is_empty():
		print("Checkpoint data not found")
		return false
	
	# Load the stage if different
	var checkpoint_stage = checkpoint_info.get("stage_path", "")
	
	if current_stage.scene_file_path != checkpoint_stage and not checkpoint_stage.is_empty():
		return false
	
	# Can change stage if different but not implemented yet to test
	#	change_stage(checkpoint_stage, "")
	#	# Wait for scene to load
	#	await get_tree().process_frame
	
	if player == null:
		print("Player not found for respawn")
		return false
	
	var player_state: Dictionary = checkpoint_info.get("player_state")
	if player_state == null:
		return false
	player.load_state(player_state)
	print("Player respawned at checkpoint: ", current_checkpoint_id)
	return true

#check if there is a checkpoint
func has_checkpoint() -> bool:
	return not current_checkpoint_id.is_empty()

# Save checkpoint data to persistent storage
func save_checkpoint_data() -> void:
	var save_data = {
		"current_checkpoint_id": current_checkpoint_id,
		"checkpoint_data": checkpoint_data
	}
	SaveSystem.save_checkpoint_data(save_data)

# Load checkpoint data from persistent storage
func load_checkpoint_data() -> void:
	var save_data = SaveSystem.load_checkpoint_data()
	if not save_data.is_empty():
		current_checkpoint_id = save_data.get("current_checkpoint_id", "")
		checkpoint_data = save_data.get("checkpoint_data", {})
		print("Checkpoint data loaded from save file")

# Clear all checkpoint data
func clear_checkpoint_data() -> void:
	current_checkpoint_id = ""
	checkpoint_data.clear()
	SaveSystem.delete_save_file()
	print("All checkpoint data cleared")

func respawn_at_begin() -> bool:
	if player == null:
		print("Player not found")
		return false
	
	if current_stage == null:
		print("Current stage not set")
		return false
	
	var begin_node = current_stage.find_child("Begin", true, false)
	if begin_node == null:
		print("Begin node not found in this stage")
		return false
	
	player.global_position = begin_node.global_position
	print("Player respawned at Begin")
	return true

func level_completed(level_id: String, elapsed_time: float):
	# Write time and completed level
	UserSystem.record_level_completion(level_id, elapsed_time)
	
	# Update coins for user
	var coin_reward = calculate_reward(elapsed_time)
	var player_data: PlayerData = get_node("/root/PlayerData")
	player_data.player_coins += coin_reward
	player_data.coins_changed.emit(player_data.player_coins)
	player_data.save_upgrades()

func calculate_reward(time: float) -> int:
	return 100 + max(0, int(100/time))
