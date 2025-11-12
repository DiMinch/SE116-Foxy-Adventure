extends PlayerState

var stats_x := -150
var stats_y := -250

const INVINCIBLE_DURATION := 2.0
const BLINK_INTERVAL := 0.1

func _enter() -> void:
	obj.change_animation("hurt")
	# Knockback
	obj.velocity.y = stats_x
	obj.velocity.x = stats_y * sign(obj.velocity.x)

	timer = 0.5  # sau 0.5s cho phép về idle (nhưng miễn nhiễm vẫn đủ 2s)

	_start_invincibility()  # nhấp nháy + miễn nhiễm 2s


func _update(delta: float) -> void:
	if update_timer(delta):
		change_state(fsm.states.idle)


# --------------------- Invincibility & Blink (không đụng tới thuộc tính Player) ---------------------

func _start_invincibility() -> void:
	# Nếu đã đang invincible (check qua metadata) thì thôi
	if obj.has_meta("invincible") and obj.get_meta("invincible") == true:
		return

	# Đánh dấu invincible bằng metadata (không vi phạm typing)
	obj.set_meta("invincible", true)

	# Tắt HurtBox nếu có (tránh ăn hit)
	var hurtbox := _find_hurtbox()
	var prev_monitoring := false
	if hurtbox:
		prev_monitoring = hurtbox.monitoring
		hurtbox.monitoring = false

	# Chạy nhấp nháy trong 2s rồi tự khôi phục
	_blink_for_duration(INVINCIBLE_DURATION, BLINK_INTERVAL, hurtbox, prev_monitoring)


func _blink_for_duration(duration: float, interval: float, hurtbox: Area2D, prev_monitoring: bool) -> void:
	var elapsed := 0.0
	var original_visible := obj.visible

	while elapsed < duration and is_instance_valid(obj):
		obj.visible = not obj.visible
		await get_tree().create_timer(interval).timeout
		elapsed += interval

	# Khôi phục
	if is_instance_valid(obj):
		obj.visible = original_visible
		obj.set_meta("invincible", false)  # bỏ cờ meta
		if hurtbox and is_instance_valid(hurtbox):
			hurtbox.monitoring = prev_monitoring


func _find_hurtbox() -> Area2D:
	# Ưu tiên node tên "HurtBox"
	var hb := obj.get_node_or_null("HurtBox")
	if hb and hb is Area2D:
		return hb
	# Hoặc tìm theo group (nếu bạn add vào group "HurtBox")
	for child in obj.get_children():
		if child is Area2D and (child.is_in_group("HurtBox") or child.name.to_lower().find("hurt") != -1):
			return child
	return null
