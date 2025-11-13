class_name Player
extends BaseCharacter

@export var blade_speed:float =300
@onready var blade_factory := $Direction/BladeFactory
@onready var onHurt := $Direction/HurtArea2D

## Player character class that handles movement, combat, and state management
var is_invulnerable: bool = false
@export var invulnerable_time := 2.0
@export var has_blade: bool = false

func _ready() -> void:
	add_to_group("player")
	super._ready()
	
	self.max_health = PlayerConstants.PLAYER_STATS[EnumKeys.PlayerKeys.HEALTH]
	self.movement_speed = PlayerConstants.PLAYER_STATS[EnumKeys.PlayerKeys.MOVEMENT_SPEED]
	self.jump_speed = PlayerConstants.PLAYER_STATS[EnumKeys.PlayerKeys.JUMP_SPEED]
	self.gravity = PlayerConstants.PLAYER_STATS[EnumKeys.PlayerKeys.GRAVITY]
	self.attack_damage = PlayerConstants.PLAYER_STATS[EnumKeys.PlayerKeys.ATTACK_DAMAGE]

	self.health = self.max_health
	
	fsm = FSM.new(self, $States, $States/Idle)
	if has_blade:
		collected_blade()
	GameManager.player = self

func can_attack() -> bool:
	if fsm.current_state == fsm.states.run or fsm.current_state == fsm.states.idle :
		return true
	return has_blade

func collected_blade() -> void:
	has_blade = true
	set_animated_sprite($Direction/BladeAnimatedSprite2D)

func save_state() -> Dictionary:
	return {
		"position": [global_position.x, global_position.y]
	}

func load_state(data: Dictionary) -> void:
	"""Load player state from checkpoint data"""
	if data.has("position"):
		var pos_array = data["position"]
		global_position = Vector2(pos_array[0], pos_array[1])

 
func Throw()->void:

	var Blade :=blade_factory.create() as RigidBody2D
	Blade.add_collision_exception_with(self)
	var blade_velocity:=Vector2(blade_speed*direction,0.0)
	
	Blade.apply_impulse(blade_velocity)

func _on_hurt_area_2d_hurt(_direction: Variant, _damage: Variant) -> void:
	if is_invulnerable:
		return
	fsm.current_state.take_damage(_damage)

func start_invulnerability():
	is_invulnerable = true
	onHurt.monitoring = false
	
	_blink_effect()
	await get_tree().create_timer(invulnerable_time).timeout
	is_invulnerable = false
	_stop_blink_effect()
	
	await get_tree().process_frame
	onHurt.monitoring = true

func _blink_effect():
	var sprite = _next_animated_sprite
	var tween = create_tween()
	tween.set_loops()
	tween.tween_property(sprite, "modulate:a", 0.3, 0.1).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	tween.tween_property(sprite, "modulate:a", 1.0, 0.1)
	sprite.set_meta("blink_tween", tween)

func _stop_blink_effect():
	var sprite = _next_animated_sprite
	if sprite.has_meta("blink_tween"):
		var tween = sprite.get_meta("blink_tween")
		tween.kill()
		sprite.remove_meta("blink_tween")
		sprite.modulate.a = 1.0
