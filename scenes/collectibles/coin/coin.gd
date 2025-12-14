extends CollectibleBase

@export var coin_amount: int = 1

func collect() -> void:
	GameManager.inventory_system.add_currency("coins", coin_amount)
	play_and_free("pick")
	
	AudioManager.play_sound("coin_collect")
