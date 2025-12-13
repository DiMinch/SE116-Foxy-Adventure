@tool
extends EditorScript

# --- CẤU HÌNH ---
const SFX_SOURCE_DIR = "res://assets/audio/sfx/"
const SFX_RESOURCE_DIR = "res://data/audio/clips/"
const DATABASE_PATH = "res://data/audio/audio_database.tres"

# Biến tạm để chứa danh sách resource tìm được
var _temp_valid_resources: Array[AudioClip] = []

func _run():
	print("--- BẮT ĐẦU ĐỒNG BỘ AUDIO (RECURSIVE) ---")
	
	# 1. Reset danh sách tạm
	_temp_valid_resources.clear()
	
	# 2. Tạo thư mục đích nếu chưa có
	var dir = DirAccess.open("res://")
	if not dir.dir_exists(SFX_RESOURCE_DIR):
		dir.make_dir_recursive(SFX_RESOURCE_DIR)
	
	# 3. Bắt đầu quét đệ quy từ thư mục gốc
	var root_dir = DirAccess.open(SFX_SOURCE_DIR)
	if root_dir:
		_scan_directory_recursive(SFX_SOURCE_DIR)
	else:
		push_error("Không tìm thấy thư mục nguồn: " + SFX_SOURCE_DIR)
		return

	# 4. Cập nhật Database
	_update_database(_temp_valid_resources)
	
	print("--- HOÀN TẤT ĐỒNG BỘ ---")

# --- HÀM QUÉT ĐỆ QUY ---
func _scan_directory_recursive(path: String):
	var dir = DirAccess.open(path)
	if dir:
		dir.list_dir_begin()
		var file_name = dir.get_next()
		
		while file_name != "":
			if dir.current_is_dir():
				# Nếu là thư mục -> Gọi đệ quy để quét sâu hơn
				# Bỏ qua các thư mục ẩn (bắt đầu bằng .)
				if not file_name.begins_with("."):
					var sub_path = path + file_name + "/"
					_scan_directory_recursive(sub_path)
			else:
				# Nếu là file -> Kiểm tra và xử lý
				if _is_audio_file(file_name):
					# Lưu ý: Truyền đường dẫn đầy đủ (path + file_name)
					var clip_resource = _process_audio_file(path, file_name)
					if clip_resource:
						_temp_valid_resources.append(clip_resource)
			
			file_name = dir.get_next()
		dir.list_dir_end()

func _is_audio_file(file_name: String) -> bool:
	return file_name.ends_with(".wav") or file_name.ends_with(".ogg") or file_name.ends_with(".mp3")

func _process_audio_file(dir_path: String, file_name: String) -> AudioClip:
	var file_id = file_name.get_basename() # ID vẫn là tên file (ví dụ: "jump")
	
	var resource_path = SFX_RESOURCE_DIR + file_id + ".tres"
	var full_audio_path = dir_path + file_name
	
	var clip_res: AudioClip
	
	# A. Load cũ nếu có
	if FileAccess.file_exists(resource_path):
		clip_res = load(resource_path) as AudioClip
	
	# B. Tạo mới nếu chưa có
	if clip_res == null:
		clip_res = AudioClip.new()
		clip_res.clip_id = file_id
		clip_res.randomize_pitch = true # Default setting
		print("Tạo mới: " + file_id + " (từ " + dir_path + ")")
		
	# C. Cập nhật stream
	clip_res.stream = load(full_audio_path)
	
	# D. Lưu
	var error = ResourceSaver.save(clip_res, resource_path)
	if error != OK:
		push_error("Lỗi lưu resource: " + resource_path)
		return null
		
	return clip_res

func _update_database(new_clips_list: Array[AudioClip]):
	# (Giữ nguyên logic cập nhật database như cũ)
	if not FileAccess.file_exists(DATABASE_PATH):
		push_error("Không tìm thấy Database")
		return
	
	var db = load(DATABASE_PATH) as AudioDatabase
	if not db: return
	
	db.clips = new_clips_list
	ResourceSaver.save(db, DATABASE_PATH)
	print("Đã cập nhật Database với " + str(new_clips_list.size()) + " clips.")
