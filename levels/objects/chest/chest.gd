extends InteractiveArea2D

@export var coin_reward: int = 5
@export var used_key: int = 1
@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
var is_opened: bool = false

func _ready():
	interacted.connect(_on_interacted)
	animated_sprite.play("close")

func _on_interacted():
	attempt_open_chest()

func attempt_open_chest():
	if is_opened:
		return
	if GameManager.inventory_system.has_key():
		open_chest()

func open_chest():
	if is_opened:
		return
	is_opened = true
	GameManager.inventory_system.use_currency("keys", used_key)
	animated_sprite.play("open")
	await animated_sprite.animation_finished
	GameManager.inventory_system.add_currency("coins", coin_reward)
	print("Chest opened! You received ",coin_reward, " coin!")
	
	AudioManager.play_sound("open_chest")
