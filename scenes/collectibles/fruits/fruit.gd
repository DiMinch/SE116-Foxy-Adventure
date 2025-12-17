extends CollectibleBase
class_name Fruit

@export_enum("Apple", "Grapes", "Strawberry") var fruit_type: String = "Apple"

@export_group("Reward")
@export var coins_reward: int = 2
@export var value: int = 1

const RESPAWN_TIME: float = 5.0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var is_active: bool = true

func _ready() -> void:
	super._ready()
	var timer = Timer.new()
	add_child(timer)
	timer.one_shot = true
	timer.name = "RespawnTimer"
	timer.timeout.connect(respawn_fruit)

func collect() -> void:
	if not is_active:
		return
	
	is_active = false
	AudioManager.play_sound("food_collect")
	# Add fruit count
	GameManager.inventory_system.add_consumable("fruits", 1)
	# Add coin reward
	if coins_reward > 0:
		GameManager.inventory_system.add_consumable("coins", coins_reward)
	# Apply power-up
	if fruit_type == "Apple":
		GameManager.player.restore_health(value)
	if fruit_type == "Grapes":
		GameManager.player.collect_powerup("speed_up")
	if fruit_type == "Strawberry":
		GameManager.player.collect_powerup("high_jump")
	
	hide_and_start_timer()

func hide_and_start_timer():
	animated_sprite.visible = false
	collision_shape.disabled = true
	
	var timer: Timer = get_node("RespawnTimer")
	timer.start(RESPAWN_TIME)
	print(fruit_type + " collected. Will respawn in %s seconds." % RESPAWN_TIME)

func respawn_fruit():
	is_active = true
	animated_sprite.visible = true
	collision_shape.disabled = false
	
	animated_sprite.modulate = Color(1, 1, 1, 0)
	var tween = create_tween()
	tween.tween_property(animated_sprite, "modulate", Color(1, 1, 1, 1), 0.5)
	
	print("Fruit respawned: ", fruit_type)
