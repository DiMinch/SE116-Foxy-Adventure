extends Control

var skill_nodes_map = {}

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
				"node": node,
				"center": node.position + node.size / 2
			}
		elif node.get_child_count() > 0:
			_scan_stage_children(node)

func _on_skill_unlocked(_skill_id):
	queue_redraw()

func _draw():
	for skill_id in skill_nodes_map.keys():
		var skill_info = skill_nodes_map[skill_id]
		var node: SkillNode = skill_info["node"]
		var end_pos: Vector2 = skill_info["center"]
		var skill_data = node.skill_data
		if not skill_data:
			continue
		for pre_id in skill_data.prerequisites:
			if skill_nodes_map.has(pre_id):
				var pre_center = skill_nodes_map[pre_id]["center"]
				var color = unlocked_color if PlayerData.has_skill(pre_id) else locked_color
				draw_line(pre_center, end_pos, color, 2.0, true)
