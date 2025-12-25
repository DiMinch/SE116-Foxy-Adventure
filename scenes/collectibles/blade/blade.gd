extends CollectibleBase

func collect() -> void:
	GameManager.player.collect_powerup("blade")
	play_and_free("pick")
	
	AudioManager.play_sound("coin_collect")
