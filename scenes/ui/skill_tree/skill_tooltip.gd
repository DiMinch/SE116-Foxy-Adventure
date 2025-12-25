extends Control
class_name SkillTooltip

@onready var label: RichTextLabel = $PanelContainer/MarginContainer/InfoLabel

func show_info(skill_data: SkillData, at_pos: Vector2) -> void:
	if not skill_data:
		return

	var text = ""
	text += "[color=gold][b]Kĩ năng:\t%s[/b][/color]\n" % skill_data.skill_name
	text += "[b]Bậc:[/b]\t[color=cyan]%d[/color]\n" % skill_data.tier
	text += "[b]Giá:[/b]\t[color=green]%d Coins[/color]\n\n" % skill_data.cost
	
	var prereq_text = "Không"
	if skill_data.prerequisites.size() > 0:
		prereq_text = ", ".join(skill_data.prerequisites.map(func(p): return str(p)))
	text += "[b]Yêu cầu:\t[/b][i]%s[/i]\n\n" % prereq_text
	
	text += "[b]Mô tả:\t[/b][color=light_gray]%s[/color]\n" % skill_data.description
	
	if skill_data.type == "W" and skill_data.weapons_to_unlock:
		var weapon_names = ", ".join(skill_data.weapons_to_unlock.map(func(w): return w.weapon_name))
		text += "\n[color=orange][b]Mở khóa:[/b]\t%s[/color]" % weapon_names
	
	label.bbcode_enabled = true
	label.text = text
	
	position = at_pos
	visible = true

func hide_info() -> void:
	visible = false
