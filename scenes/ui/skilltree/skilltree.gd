extends Control

var skill_nodes_map = {}
var dragging := false

@export var unlocked_color: Color = Color(1.0, 1.0, 0.204)
@export var locked_color: Color = Color(0.5, 0.5, 0.5, 0.5)

func _ready():
	skill_nodes_map.clear()
	_scan_stage_children(self)
	# Đảm bảo PlayerData tồn tại trước khi kết nối signal
	if Engine.has_singleton("PlayerData"): 
		PlayerData.skill_unlocked.connect(_on_skill_unlocked)
	
	# Kích hoạt _draw lần đầu
	queue_redraw()

func _scan_stage_children(parent: Node) -> void:
	for node in parent.get_children():
		if node is SkillNode and node.skill_data:
			skill_nodes_map[node.skill_data.skill_id] = {
				"node": node
			}
		elif node.get_child_count() > 0:
			_scan_stage_children(node)

func _on_skill_unlocked(_skill_id):
	# Yêu cầu vẽ lại đường nối khi có skill mới được mở khóa
	queue_redraw()

func _draw():
	# Lấy vị trí toàn cục của Node SkillTree (self) làm gốc tọa độ vẽ.
	var self_global_pos = global_position 
	
	for skill_id in skill_nodes_map.keys():
		var skill_info = skill_nodes_map[skill_id]
		var node: SkillNode = skill_info["node"]
		
		# 1. Tính Tọa độ tâm toàn cục của Node Skill.
		var end_pos_global = node.global_position + node.size / 2
		
		# 2. Chuyển Tọa độ Toàn cục về Cục bộ (Tọa độ Icon - Tọa độ Gốc của Node vẽ).
		var end_pos: Vector2 = end_pos_global - self_global_pos
		
		var skill_data = node.skill_data
		if not skill_data:
			continue
		for pre_id in skill_data.prerequisites:
			if skill_nodes_map.has(pre_id):
				var pre_node_info = skill_nodes_map[pre_id]
				var pre_node: SkillNode = pre_node_info["node"]
				
				var pre_center_global = pre_node.global_position + pre_node.size / 2
				var pre_center: Vector2 = pre_center_global - self_global_pos
				
				var color = unlocked_color if PlayerData.has_skill(pre_id) else locked_color
				draw_line(pre_center, end_pos, color, 2.0, true)
				
func _gui_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			dragging = event.pressed
			# Không cần lưu last_pos khi dùng event.relative
			
	if event is InputEventMouseMotion:
		# event.relative.length_squared() > 0 đảm bảo chỉ cuộn khi có di chuyển
		if dragging and event.relative.length_squared() > 0:
			var scroll_container = get_parent()
			
			# CẬP NHẬT SCROLL CONTAINER DỰA TRÊN ĐỘ DỊCH CHUỘT (event.relative)
			# Giá trị trừ đi event.relative là chính xác cho logic kéo chuột (Drag)
			scroll_container.scroll_horizontal -= event.relative.x 
			scroll_container.scroll_vertical -= event.relative.y
			
			# Yêu cầu vẽ lại đường nối tại vị trí mới.
			queue_redraw()
