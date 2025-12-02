extends PopupPanel
class_name SkillPopup

@onready var info_label: RichTextLabel = $InfoLabel

func show_skill_info(skill_data: SkillData) -> void:
	if not skill_data:
		return
	
	var text = ""
	text += "[b]Name:[/b] %s\n" % skill_data.skill_name
	text += "[b]Tier:[/b] %d\n" % skill_data.tier
	text += "[b]Cost:[/b] %d\n" % skill_data.cost
	
	var prereq_text = "None"
	if skill_data.prerequisites.size() > 0:
		var prereq_strings = []
		for p in skill_data.prerequisites:
			prereq_strings.append(str(p))
		prereq_text = ", ".join(prereq_strings)
	text += "[b]Prerequisites:[/b] %s\n" % prereq_text
	
	text += "[b]Description:[/b] %s\n" % skill_data.description
	
	if skill_data.type == "W" and skill_data.weapon_to_unlock:
		text += "[b]Unlocks Weapon:[/b] %s\n" % skill_data.weapon_to_unlock.weapon_name
	
	info_label.bbcode_enabled = true
	info_label.bbcode_text = text
	info_label.scroll_to_line(0)
	
	popup()
