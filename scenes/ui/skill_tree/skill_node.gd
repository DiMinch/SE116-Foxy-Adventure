extends TextureButton
class_name SkillNode

@export var skill_data: SkillData
@onready var panel: Panel = $Panel
@onready var label: Label = $MarginContainer/Label
var tooltip: SkillTooltip

func _ready():
	var tooltips = get_tree().get_nodes_in_group("skill_tooltip")
	if tooltips.size() > 0:
		tooltip = tooltips[0]
	
	self.mouse_filter = Control.MOUSE_FILTER_STOP
	panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	
	PlayerData.skill_unlocked.connect(update_visuals)
	PlayerData.coins_changed.connect(update_visuals)
	
	if skill_data:
		label.text = skill_data.skill_name
		texture_normal = skill_data.icon
	
	if not is_connected("pressed", _on_pressed):
		pressed.connect(_on_pressed)
	update_visuals()

func update_visuals(_value = null):
	if not skill_data:
		panel.visible = true
		self.disabled = true
		return
	
	if PlayerData.has_skill(skill_data.skill_id):
		panel.visible = false
		self.disabled = false
		self.modulate = Color(1.0, 1.0, 1.0)
	else:
		if PlayerData.can_upgrade(skill_data):
			self.disabled = false
			panel.visible = true
			panel.modulate = Color(0.8, 1, 0.8)
		else:
			self.disabled = true
			panel.visible = true
			panel.modulate = Color(0.5, 0.5, 0.5, 0.5)

func _on_pressed():
	print("Pressed")
	if skill_data and PlayerData.can_upgrade(skill_data):
		PlayerData.upgrade_skill(skill_data)
		update_visuals()

func _on_mouse_entered() -> void:
	if not skill_data or not tooltip:
		return
	
	var node_pos = get_global_position()
	var node_size = size
	var viewport_size = get_viewport_rect().size
	
	var tooltip_pos = Vector2()
	if node_pos.y < viewport_size.y * 0.5:
		tooltip_pos = node_pos + Vector2(0, node_size.y + 3)
	else:
		tooltip_pos = node_pos - Vector2(0, tooltip.size.y + 3)
	
	tooltip.show_info(skill_data, tooltip_pos)

func _on_mouse_exited():
	if tooltip:
		tooltip.hide_info()
