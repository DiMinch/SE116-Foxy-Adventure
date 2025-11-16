extends Control
class_name SkillTooltip

@onready var label: RichTextLabel = $Panel/InfoLabel

func show_info(skill_data: SkillData, at_pos: Vector2) -> void:
	if not skill_data:
		return

	var text = ""
	text += "[b]Name:[/b] %s\n" % skill_data.skill_name
	text += "[b]Tier:[/b] %d\n" % skill_data.tier
	text += "[b]Cost:[/b] %d\n" % skill_data.cost

	if skill_data.prerequisites.size() > 0:
		var prereqs = []
		for p in skill_data.prerequisites:
			prereqs.append(str(p))
		text += "[b]Prerequisites:[/b] %s\n" % ", ".join(prereqs)
	else:
		text += "[b]Prerequisites:[/b] None\n"

	text += "[b]Description:[/b] %s\n" % skill_data.description

	if skill_data.type == "W" and skill_data.weapon_to_unlock:
		text += "[b]Unlocks Weapon:[/b] %s\n" % skill_data.weapon_to_unlock.weapon_name

	label.bbcode_text = text

	position = at_pos
	visible = true

func hide_info() -> void:
	visible = false
