extends EnemyState

@export var fade_speed := 5   # càng lớn fade càng nhanh

var _fading := false

func _enter() -> void:
	obj.Hit.monitoring=false
	obj.hurt.disabled =true
	#print("ENTER DEAD, alpha =", obj.sprite.modulate.a)
	obj.change_animation("idle")
	obj.sprite.stop()
	obj.sprite.frame = 0
	_fading = true
	GameManager.inventory_system.add_currency("keys", 1)
	GameManager.inventory_system.add_currency("coins", 10)
	
	AudioManager.play_sound("war_lord_dead")

func _update(delta: float) -> void:
	obj.velocity.x=0
	if _fading:
		fade_out(delta)

func fade_out(delta: float) -> void:
	obj.sprite.modulate.a = max(obj.sprite.modulate.a - fade_speed * delta, 0.0)
	if obj.sprite.modulate.a <= 0.0:
		obj.queue_free()  # hoặc queue_free() nếu state nằm cùng node enemy
