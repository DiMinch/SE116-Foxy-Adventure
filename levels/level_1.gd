extends Stage

const OPENING_CUTSCENE = preload("res://dialog/cutscenes/opening_cutscene.tscn")

func _ready():
	play_opening_cutscene()
func _exit_tree():
	cleanup_dialogic()

func cleanup_dialogic():
	if Dialogic.current_timeline != null:
		Dialogic.end_timeline()
	
	if Dialogic.timeline_ended.is_connected(_on_level_timeline_ended):
		Dialogic.timeline_ended.disconnect(_on_level_timeline_ended)
	
	var dialog_node = Dialogic.Styles.get_layout_node()
	if dialog_node and dialog_node.has_method("unregister_character"):
		var foxy_resource = load("res://dialog/characters/foxy.dch")
		if foxy_resource:
			dialog_node.unregister_character(foxy_resource)

func play_opening_cutscene():
	var cutscene = OPENING_CUTSCENE.instantiate()
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 0
	add_child(canvas_layer)
	canvas_layer.add_child(cutscene)
	
	cutscene.cutscene_finished.connect(func():
		canvas_layer.queue_free()
		start_level_logic()
	)

func start_level_logic():
	super._ready()
	Dialogic.start("start")
	if not Dialogic.timeline_ended.is_connected(_on_level_timeline_ended):
		Dialogic.timeline_ended.connect(_on_level_timeline_ended)

func _on_level_timeline_ended():
	if Dialogic.timeline_ended.is_connected(_on_level_timeline_ended):
		Dialogic.timeline_ended.disconnect(_on_level_timeline_ended)
	if is_ambient_dialogue:
		is_ambient_dialogue = false
		Dialogic.Inputs.auto_advance.enabled_forced = false
		Dialogic.Inputs.manual_advance.system_enabled = true
		var bubbles = get_tree().get_nodes_in_group("dialogic_layout")
		for b in bubbles:
			b.queue_free()
	await get_tree().create_timer(1.0).timeout
	trigger_ambient_dialogue()

func trigger_ambient_dialogue():
	is_ambient_dialogue = true
	var dialog_node = Dialogic.Styles.load_style("bubble_style")
	var foxy_resource = load("res://dialog/characters/foxy.dch")
		 
	if dialog_node and foxy_resource and GameManager.player:
		if dialog_node.has_method("register_character"):
			dialog_node.register_character(foxy_resource, GameManager.player)
			Dialogic.start("level1")
			Dialogic.Inputs.auto_advance.enabled_forced = true
			await get_tree().create_timer(1.0).timeout
			Dialogic.Inputs.manual_advance.system_enabled = false
		else:
			print("[DIALOGUE] Giao diện hiện tại không hỗ trợ register_character")
