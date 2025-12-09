extends EnemyCharacter
@onready var is_in_attack_range =false
@onready var is_atk1=true
@onready var is_short=true
@onready var is_take_a_rest=false
func _ready() -> void:
	fsm = FSM.new(self, $States, $States/Idle)
	#enemy_type = "Starfish"
	enemy_type = "WarLord"
	super._ready()
