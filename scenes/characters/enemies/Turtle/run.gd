extends "res://scenes/characters/player/states/run.gd"

var _timer: float = 3.0   # chạy 3 giây rồi chui vào mai

@export var movement_range: float = 200.0  # phạm vi di chuyển

var _start_x: float
var _left_limit: float
var _right_limit: float

func _enter() -> void:
	_timer = 3.0          # reset mỗi khi vào Run

	# lấy vị trí hiện tại làm tâm của movement_range
	_start_x = obj.global_position.x
	var half := movement_range * 0.5
	_left_limit = _start_x - half
	_right_limit = _start_x + half

	super._enter()        # gọi _enter gốc của run.gd


func _update(delta: float) -> void:
	# đếm thời gian để chui vào mai
	_timer -= delta
	if _timer <= 0.0:
		change_state(fsm.states.intoshell)
		return

	# logic chạy gốc của run.gd (di chuyển + quay đầu khi chạm tường / sắp rơi)
	super._update(delta)

	# GIỚI HẠN TRONG movement_range
	var x := obj.global_position.x

	# nếu đang đi sang phải và vượt biên phải thì quay đầu
	if obj.direction > 0 and x > _right_limit:
		obj.turn_around()

	# nếu đang đi sang trái và vượt biên trái thì quay đầu
	elif obj.direction < 0 and x < _left_limit:
		obj.turn_around()
