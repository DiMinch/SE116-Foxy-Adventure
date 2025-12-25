extends EnemyCharacter

@onready var is_in_attack_range = false
@onready var is_atk1 = true
@onready var is_short = true
@onready var is_take_a_rest = false
@onready var is_being_hurt = false
@onready var sprite = $Direction/AnimatedSprite2D
@onready var Hit = $Direction/HitArea2D
@onready var hp_bar = $EnemyHpBarBoss
@onready var hurt =$Direction/HurtArea2D/CollisionShape2D

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Idle)
	enemy_type = "WarLord"
	super._ready()

func _on_hit_area_2d_hitted(_area: Variant) -> void:
	pass # Replace with function body.
