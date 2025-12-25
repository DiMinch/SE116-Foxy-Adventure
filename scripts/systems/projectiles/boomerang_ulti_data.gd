@tool
extends UltiData
class_name BoomerangUlti

@export_category("Atomic Stats")
@export var enemy_hp_percent: float = 0.5
@export var self_hp_cost: float = 0.25
@export var fly_speed: float = 600.0
@export var fly_distance: float = 400.0
@export var return_accel: float = 1200.0
@export var package_scene: PackedScene
