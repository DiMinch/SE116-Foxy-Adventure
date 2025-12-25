extends MarginContainer

signal next_level_pressed(stage_path, door_name)
signal retry_pressed()

@export_file("*.tscn") var home_path = "res://scenes/screens/main_screen.tscn"

@onready var header = $NinePatchRect/VBoxContainer/Header
# Victory
@onready var vic_container = $NinePatchRect/VBoxContainer/VictoryCointainer
@onready var vic_time = $NinePatchRect/VBoxContainer/VictoryCointainer/ResultContainer/TimeLabel
@onready var vic_coin = $NinePatchRect/VBoxContainer/VictoryCointainer/ResultContainer/CoinLabel
@onready var vic_extra_coin = $NinePatchRect/VBoxContainer/VictoryCointainer/ResultContainer/ExtraCoinLabel
@onready var vic_best = $NinePatchRect/VBoxContainer/VictoryCointainer/ResultContainer/BestLabel
@onready var vic_coin_reward = $NinePatchRect/VBoxContainer/VictoryCointainer/ResultContainer/CoinRewardLabel
# Defeat
@onready var def_container = $NinePatchRect/VBoxContainer/DefeatContainer
@onready var def_coin = $NinePatchRect/VBoxContainer/DefeatContainer/ResultContainer/CoinLabel
@onready var def_reason = $NinePatchRect/VBoxContainer/DefeatContainer/ResultContainer/DefeatReason
# Button
@onready var retry_btn = $NinePatchRect/VBoxContainer/ButtonContainer/RetryButton
@onready var home_btn = $NinePatchRect/VBoxContainer/ButtonContainer/HomeButton
@onready var next_button = $NinePatchRect/VBoxContainer/ButtonContainer/NextButton

var data: Dictionary = {}
var target_stage = ""
var target_door = ""

func _ready() -> void:
	retry_btn.pressed.connect(_on_retry_pressed)
	home_btn.pressed.connect(_on_home_pressed)
	next_button.pressed.connect(_on_next_pressed)

func setup_result(is_victory: bool, result_data: Dictionary):
	data = result_data
	target_stage = data.get("next_stage", "")
	target_door = data.get("next_door", "Begin")
	
	if is_victory:
		setup_victory()
	else:
		setup_defeat()

func setup_victory():
	header.text = "VICTORY"
	vic_container.show()
	def_container.hide()
	next_button.show()
	
	vic_time.text = _format_time(data.get("elapsed_time", 0.0))
	vic_coin.text = str(data.get("collected", 0))
	vic_extra_coin.text = str(data.get("extra_coins", 0))
	vic_best.text = str(data.get("record", 0))
	vic_coin_reward.text = "+" + str(data.get("added", 0))

func setup_defeat():
	header.text = "DEFEAT"
	vic_container.hide()
	def_container.show()
	next_button.hide()
	
	def_coin.text = "Số xu thu thập: " + str(data.get("collected", 0))
	def_reason.text = data.get("fail_reason", "Just die :P!")

func _format_time(seconds: float) -> String:
	var minutes = int(seconds  / 60)
	var secs = int(seconds) % 60
	return "%02d:%02d" % [minutes, secs]

func _on_retry_pressed():
	get_tree().paused = false
	retry_pressed.emit()
	hide()

func _on_home_pressed():
	get_tree().paused = false
	GameManager.change_stage(home_path, "Begin2")

func _on_next_pressed():
	get_tree().paused = false
	next_level_pressed.emit(target_stage, target_door)
