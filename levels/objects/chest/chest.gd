extends Node2D
class_name Chest

@export_group("Reward Settings")
@export var coin_reward: int = 5
@export var key_reward: int = 1

@export_group("Reward Scenes")
@export var coin_scene: PackedScene
@export var key_scene: PackedScene

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var interactive_area: InteractiveArea2D = $InteractiveArea2D

var is_opened: bool = false

func _ready():
	interactive_area.set_collision_mask_value(2, true)
	animated_sprite.play("close")
	is_opened = false

func _on_interactive_area_2d_interacted() -> void:
	attempt_open_chest()

func attempt_open_chest():
	if is_opened:
		return
	is_opened = true
	open_chest()

func open_chest():
	if coin_scene == null and key_scene == null:
		push_warning("Chest: Thiếu PackedScene của Coin hoặc Key")
		return
	
	is_opened = true
	animated_sprite.play("open")
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
	item_instance.global_position = base_position
	
	var angle = randf() * TAU
	var radius = 20 + (index % 5) * 5
	var target_pos = base_position + Vector2(cos(angle) * radius, sin(angle) * radius)
	
	var space_state = get_world_2d().direct_space_state
	var query = PhysicsPointQueryParameters2D.new()
	query.position = target_pos
	query.collision_mask = 1
	
	var collision = space_state.intersect_point(query)
	if not collision.is_empty():
		target_pos = base_position + (target_pos - base_position) * 0.3
	# Effect
	var tween = create_tween().set_parallel(true).set_trans(Tween.TRANS_SINE)
	
	tween.tween_property(item_instance, "global_position:x", target_pos.x, 0.5)
	
	var jump_height = 20.0
	tween.tween_property(item_instance, "global_position:y", base_position.y - jump_height, 0.25).set_ease(Tween.EASE_OUT)
	tween.tween_property(item_instance, "global_position:y", target_pos.y, 0.25).set_delay(0.25).set_ease(Tween.EASE_IN)
