extends EnemyCharacter
class_name KingCrab

@export var attack_range: float = 800
@export var enemySpawn: PackedScene = null

@onready var start_detect_player = false
@onready var is_being_hurt = false
@onready var bullet_factory := $Direction/Node2DFactory
@onready var is_atk1 = true
@onready var Hit = $Direction/HitArea2D
@onready var hp_bar = $EnemyHpBarBoss
@onready var sprite = $Direction/AnimatedSprite2D
@onready var hurt = $Direction/HurtArea2D/CollisionShape2D

func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Run)
	enemy_type = "KingCrab"
	Hit.damage = spike
	super._ready()

func spawn_minions():
	for i in range(2):
		var mini_crab = enemySpawn.instantiate()
		# Setup distance spawn
		var dir = 1 if i == 0 else -1
		var offset = Vector2(50 * dir, 0)
		mini_crab.global_position = global_position + offset
		mini_crab.direction = dir
		# Add to parent node
		get_parent().add_child(mini_crab)
