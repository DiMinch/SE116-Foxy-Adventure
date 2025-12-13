extends CollectibleBase
class_name Fruit

@export_enum("Apple", "Grapes", "Strawberry") var fruit_type: String = "Apple"
@export_enum("Heal", "Speed", "Jump") var powerup_type: String = "Heal"

@export var coins_reward: int = 2
@export var value: int = 1

func collect() -> void:
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
	queue_free()
	
	AudioManager.play_sound("food_collect")
