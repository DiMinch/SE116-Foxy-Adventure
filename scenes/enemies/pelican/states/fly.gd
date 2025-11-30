extends EnemyState
class_name EnemyFlyState

const ANIM_FLY := "fly"
const SHOOT_INTERVAL := 2

var shoot_timer: float = 0.0
var is_attack: bool = false
const STR_IS_ATTACK := "get_is_attack"
const STR_CHECK := "is_out_of_fly_range"

func _enter() -> void:
	obj.change_animation(ANIM_FLY)
	shoot_timer = 0.0
	obj.velocity.y = 0

func _update(delta: float) -> void:
	shoot_timer += delta
	
	obj.velocity.x = obj.direction * obj.movement_speed
	obj.move_and_slide()
	
	if shoot_timer >= SHOOT_INTERVAL:
		if obj.has_method(STR_IS_ATTACK):
			is_attack = obj.get_is_attack()
		if is_attack:
			shoot_timer = 0.0
			change_state(fsm.states.attack)
		return
	
	if _should_turn_around():
		obj.turn_around()

func _should_turn_around() -> bool:
	if obj.is_touch_wall():
		return true
	if obj.has_method(STR_CHECK) and obj.is_out_of_fly_range():
		return true
	return false
