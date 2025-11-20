extends Area2D
class_name GlowingBush

# --- ENUM: Định nghĩa Trạng thái và Buff ---
enum State { NORMAL, GLOWING, WITHERED }
enum BuffType { HEAL, SPEED, STEALTH, FAKE }

# --- BIẾN EXPORT & ONREADY ---
@export var is_glowing: bool = true # Dễ dàng đặt Glowing state trong Editor
@export var withered_duration: float = 1.0
@export var fake_chance: float = 0.2 # 20%

@onready var animated_sprite: AnimatedSprite2D = $AnimatedSprite2D
@onready var fireflies: Node2D = $Fireflies # Giả định là Node chứa hiệu ứng đom đóm
@onready var buff_timer: Timer = $BuffTimer
@onready var heal_timer: Timer = $HealTimer

var current_state: int = State.NORMAL
var current_buff: int = BuffType.FAKE
var active_player: Player = null

# --- READY & INITIALIZATION ---

func _ready() -> void:
	if is_glowing:
		change_state(State.GLOWING)
	else:
		change_state(State.NORMAL)
		
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	
	heal_timer.timeout.connect(_on_heal_timer_timeout)

# --- STATE MANAGEMENT ---

func change_state(new_state: int) -> void:
	current_state = new_state
	
	match current_state:
		State.NORMAL:
			animated_sprite.play("normal")
			fireflies.hide()
			monitorable = true

		State.GLOWING:
			animated_sprite.play("normal")
			fireflies.show()
			monitorable = true

		State.WITHERED:
			_start_wither_async()

func _start_wither_async() -> void:
	await get_tree().create_timer(withered_duration).timeout
	queue_free()

# --- INPUT & INTERACTION ---

func _on_body_entered(body: Node2D) -> void:
	if body is Player and current_state == State.GLOWING:
		active_player = body
		apply_random_buff(body)
		
		# Buff Stealth kết thúc khi rời khỏi, không cần héo ngay
		if current_buff != BuffType.STEALTH:
			change_state(State.WITHERED)

func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		if current_state == State.GLOWING:
			# Player rời khỏi mà chưa kích hoạt (bấm nút/hết thời gian), héo ngay
			change_state(State.WITHERED)
		
		# Buff Stealth: Nếu rời khỏi, kết thúc buff và héo
		if current_buff == BuffType.STEALTH:
			if active_player:
				active_player.remove_stealth_buff()
			change_state(State.WITHERED)
		active_player = null
		
# --- BUFF LOGIC ---

func apply_random_buff(player: Player) -> void:
	# 1. 20% Fake chance
	if randf() < fake_chance:
		current_buff = BuffType.FAKE
		print("LMAO fake bush")
		return change_state(State.WITHERED) # Héo ngay

	# 2. Random real buff
	var buff_roll = randi() % 3
	if buff_roll == 0:
		current_buff = BuffType.HEAL
	elif buff_roll == 1:
		current_buff = BuffType.SPEED
	elif buff_roll == 2:
		current_buff = BuffType.STEALTH
	
	match current_buff:
		BuffType.HEAL:
			buff_timer.wait_time = 5.0
			heal_timer.start(0.1) # Ticks mỗi 0.1s
			player.start_heal_buff(self) # Bắt đầu buff Heal trên Player
			buff_timer.start()
		BuffType.SPEED:
			buff_timer.wait_time = 5.0
			player.apply_speed_buff(1.2) # Tăng 20% (1.0 + 0.2)
			buff_timer.start()
		BuffType.STEALTH:
			player.apply_stealth_buff()
			# Stealth không dùng buff_timer, nó dùng body_exited

# --- TIMER SIGNALS ---

func _on_buff_timer_timeout() -> void:
	if active_player:
		# Kết thúc buff Speed
		if current_buff == BuffType.SPEED:
			active_player.remove_speed_buff()
		# Kết thúc buff Heal
		if current_buff == BuffType.HEAL:
			heal_timer.stop()
			active_player.remove_heal_buff()

	change_state(State.WITHERED)

func _on_heal_timer_timeout() -> void:
	if active_player and current_buff == BuffType.HEAL:
		# Hồi 10 HP/s => Hồi (10 * 0.1) = 1 HP mỗi 0.1s
		active_player.health = min(active_player.max_health, active_player.health + 1)
