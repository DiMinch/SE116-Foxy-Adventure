extends Control

var skill_nodes_map = {}
var dragging := false
var last_pos := Vector2.ZERO # Lưu vị trí toàn cục

@export var unlocked_color: Color = Color(1.0, 1.0, 0.204)
@export var locked_color: Color = Color(0.5, 0.5, 0.5, 0.5)

func _ready():
	skill_nodes_map.clear()
	_scan_stage_children(self)
	PlayerData.skill_unlocked.connect(_on_skill_unlocked)
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
	queue_redraw()
	
func _draw():
	var self_global_pos = global_position 
	for skill_id in skill_nodes_map.keys():
		var skill_info = skill_nodes_map[skill_id]
		var node: SkillNode = skill_info["node"]
		
		var end_pos_global = node.global_position + node.size / 2
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
				
func _unhandled_input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var scroll_container = get_parent() as Control
			var global_rect = Rect2(scroll_container.global_position, scroll_container.size)
			
			if event.pressed:
				if global_rect.has_point(event.global_position):
					dragging = true
					last_pos = event.global_position
			else:
				dragging = false

	if event is InputEventMouseMotion:
		if dragging and event.relative.length_squared() > 0:
			var scroll_container = get_parent()
			var delta = last_pos - event.global_position

			scroll_container.scroll_horizontal += delta.x
			scroll_container.scroll_vertical += delta.y

			last_pos = event.global_position

			get_viewport().set_input_as_handled()
			queue_redraw()

func hide_popup():
	get_parent().queue_free()

func _on_overlay_color_rect_gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		hide_popup() # Replace with function body.

func _on_close_texture_button_pressed() -> void:
	hide_popup()
