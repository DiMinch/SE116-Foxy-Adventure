extends CollectibleBase

@export var key_amount: int = 1

func collect() -> void:
	GameManager.inventory_system.add_currency("keys", key_amount)
	play_and_free("pick")
	
	AudioManager.play_sound("key_collect")
