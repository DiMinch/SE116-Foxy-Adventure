extends EnemyCharacter
class_name Pelican

#@export var bullet_speed:float =300
@onready var bullet_factory := $Direction/BulletFactory
@export var dem = 0

func _ready() -> void:
	enemy_type = "Pelican"
	fsm = FSM.new(self, $States, $States/Fly)
	super._ready()

func fire() -> void:
	var bullet := bullet_factory.create() as RigidBody2D
	bullet.setup(spike)       
	bullet.add_collision_exception_with(self)
