class_name Player
extends BaseCharacter
@export var blade_speed:float =300
@onready var blade_factory := $Direction/BladeFactory
## Player character class that handles movement, combat, and state management
var is_invulnerable: bool = false
@export var has_blade: bool = false

func _ready() -> void:
	super._ready()
	fsm = FSM.new(self, $States, $States/Idle)
	if has_blade:
		collected_blade()

func can_attack() -> bool:
	if fsm.current_state == fsm.states.run or fsm.current_state == fsm.states.idle :
		return true
	return has_blade

func collected_blade() -> void:
	has_blade = true
	set_animated_sprite($Direction/BladeAnimatedSprite2D)
			
func _on_hurt_area_2d_hurt(_direction: Variant, _damage: Variant) -> void:
	#if is_invulnerable:
	#	return # đang miễn nhiễm
	print("helo cac ban")
	fsm.current_state.take_damage(_damage)
	_start_invulnerability(2.0)
	
 
func Throw()->void:

	var Blade :=blade_factory.create() as RigidBody2D
	Blade.add_collision_exception_with(self)
	var blade_velocity:=Vector2(blade_speed*direction,0.0)
	
	Blade.apply_impulse(blade_velocity)
func _start_invulnerability(duration: float) -> void:
	is_invulnerable = true
	# đổi màu player để thấy hiệu ứng bị thương
	await get_tree().create_timer(duration).timeout
	is_invulnerable = false
 # trở lại bình thường
