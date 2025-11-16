extends Node2D

func clear():
	for c in get_children():
		c.queue_free()

func draw_line_between(a: Control, b: Control, color: Color):
	var p1 = to_local(a.rect_global_position + a.rect_size * 0.5)
	var p2 = to_local(b.rect_global_position + b.rect_size * 0.5)

	var line := Line2D.new()
	line.width = 3
	line.default_color = color
	line.points = [p1, p2]
	add_child(line)
