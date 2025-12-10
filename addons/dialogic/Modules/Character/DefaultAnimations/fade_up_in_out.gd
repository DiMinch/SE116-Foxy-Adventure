extends DialogicAnimation

func animate() -> void:
	if not node or not is_instance_valid(node) or not node.is_inside_tree() or not node.get_viewport():
		return
	var tween := (node.create_tween() as Tween)

	var start_height: float
	if node and node.is_inside_tree() and node.get_viewport():
		start_height = base_position.y + node.get_viewport().size.y / 5
	else:
		print("Error: node is null or not in tree")
		start_height = base_position.y + 54  # fallback
		return
	var end_height := base_position.y

	var start_modulation := 0.0
	var end_modulation := 1.0

	if is_reversed:
		end_height = start_height
		start_height = base_position.y
		end_modulation = 0.0
		start_modulation = 1.0

	node.position.y = start_height

	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_SINE)
	tween.set_parallel()

	var end_postion := Vector2(base_position.x, end_height)
	tween.tween_property(node, "position", end_postion, time)

	var property := get_modulation_property()

	var original_modulation: Color = node.get(property)
	original_modulation.a = start_modulation
	node.set(property, original_modulation)
	var modulation_alpha := property + ":a"

	tween.tween_property(node, modulation_alpha, end_modulation, time)

	await tween.finished
	finished_once.emit()


func _get_named_variations() -> Dictionary:
	return {
		"fade in up": {"reversed": false, "type": AnimationType.IN},
		"fade out down": {"reversed": true, "type": AnimationType.OUT},
	}
