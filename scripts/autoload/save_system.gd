extends Node

## Save system for persistent checkpoint data
const SAVE_FILE = "user://checkpoint_save.dat"

# Save checkpoint data to file
func save_checkpoint_data(data: Dictionary) -> void:
	#TODO: save checkpoint data to save file
	var file = FileAccess.open(SAVE_FILE, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open save file for writing: %s" % SAVE_FILE)
		return
	
	file.store_var(data)
	file.close()
	print("Checkpoint data saved to: ", SAVE_FILE)

# Load checkpoint data from file
func load_checkpoint_data() -> Dictionary:
	#TODO: load checkpoint data from save file
	if not has_save_file():
		print("No checkpoint save file found.")
		return {}
	
	var file = FileAccess.open(SAVE_FILE, FileAccess.READ)
	if file == null:
		push_error("Failed to open save file for reading: %s" % SAVE_FILE)
		return {}
	
	var data = file.get_var()
	file.close()
	
	# Check valid data
	if typeof(data) != TYPE_DICTIONARY:
		push_warning("Invalid checkpoint data format in save file.")
		return {}
	
	print("Checkpoint data loaded successfully.")
	return data

# Check if save file exists
func has_save_file() -> bool:
	return FileAccess.file_exists(SAVE_FILE)

# Delete save file
func delete_save_file() -> void:
	if has_save_file():
		DirAccess.remove_absolute(SAVE_FILE)
		print("Save file deleted")
