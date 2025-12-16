extends EnemyState

var timer2 = 0.0
var anim: AnimatedSprite2D

func _enter():
	timer2 = 0
	anim = obj.get_node("Direction/AnimatedSprite2D") as AnimatedSprite2D
	
	anim.play("beforedizzy")
	# Đợi animation chạy xong
	await anim.animation_finished
	# Xong beforedizzy → đổi sang dizzy
	anim.play("dizzy")
	AudioManager.play_sound("dizzy")
func _update(_delta: float) -> void:
	timer2+=_delta 
	if timer2>=2: change_state(fsm.states.run)
