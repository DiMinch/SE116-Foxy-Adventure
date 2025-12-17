extends InteractiveArea2D

@export_group("Reward Settings")
@export var coin_reward: int = 5
@export var key_reward: int = 1

@export_group("Reward Scenes")
@export var coin_scene: PackedScene
@export var key_scene: PackedScene

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_opened: bool = false

func _ready():
	interacted.connect(_on_interacted)
	animated_sprite.play("close_has_gold")
	is_opened = false

func _on_interacted():
	attempt_open_chest()

func attempt_open_chest():
	if is_opened:
		return
	open_chest()

func open_chest():
	if is_opened:
		return
	
	if coin_scene == null and key_scene == null:
		push_warning("Chest: Thiếu PackedScene của Coin hoặc Key")
		return
	
	is_opened = true
	animated_sprite.play("open_has_gold")
	AudioManager.play_sound("open_chest")
	await animated_sprite.animation_finished
	
	# Spawn Coin and Key
	var spawn_position = global_position
	
	for i in range(coin_reward):
		if coin_scene:
			spawn_item(coin_scene, spawn_position, i)
	for i in range(key_reward):
		if key_scene:
			spawn_item(key_scene, spawn_position, i + coin_reward)
	print("Chest opened! You received ",coin_reward, " coin!")

func spawn_item(scene: PackedScene, base_position: Vector2, index: int):
	var item_instance = scene.instantiate()
	get_parent().add_child(item_instance)
	
	var angle = randf() * TAU
	var radius = 20 + (index % 5) * 5
	
	item_instance.global_position = base_position + Vector2(cos(angle) * radius, sin(angle) * radius)
	# Effect
	var jump_height = 80.0
	var duration = 0.8
	var horizontal_spread = 50.0
	
	var tween = create_tween()
	tween.set_parallel(true)
	
	var final_y = item_instance.global_position.y
	tween.tween_property(item_instance, "global_position:y", final_y - jump_height, duration / 2.0).set_ease(Tween.EASE_OUT)
	tween.tween_property(item_instance, "global_position:y", final_y, duration / 2.0).set_ease(Tween.EASE_IN)
	
	var final_x = item_instance.global_position.x + randf_range(-horizontal_spread, horizontal_spread)
	tween.tween_property(item_instance, "global_position:x", final_x, duration).set_ease(Tween.EASE_OUT_IN)
