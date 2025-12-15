extends PlayerState
var anim : AnimatedSprite2D
@onready var count=1
func _enter() -> void:
	obj.change_animation(ATTACK)
	obj.velocity.x = 0
	timer = 0.3
	if obj.melee_hitbox.monitoring:
		obj.melee_hitbox.update_stat_attack()
		
	if obj.current_weapon_data.weapon_name=="Blade":
		play_slash()

func _update(delta: float) -> void:
	if update_timer(delta):
		change_state(fsm.previous_state)



func play_slash():
	anim = obj.slash
	anim.visible=true
	anim.position = Vector2(5 ,anim.position.y)
	if count==1:
		anim.scale = Vector2(0.15,0.15)
		anim.play("thin")	
		await anim.animation_finished
		anim.visible=false
		count+=1
	elif count==2:
		anim.scale =Vector2(0.15,0.15)
		anim.play("wide")
		await anim.animation_finished
		anim.scale=Vector2(0.183,0.183)
		count+=1
		anim.visible=false
	else:
		anim.scale =Vector2(0.2,0.2)
		anim.position= Vector2(20,-10)
		anim.play("mix")
		await anim.animation_finished
		anim.position= Vector2(36,-10)
		anim.scale=Vector2(0.183,0.183)
		anim.visible=false
		count=1
	if obj.melee_hitbox:
		obj.melee_hitbox.set_deferred("monitoring", false)
	
	
