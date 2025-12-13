@tool
extends UltiData
class_name ShurikenUlti

@export_category("Shuriken Stats")
@export var damage: int = 100
@export var tick_rate: float = 0.5
@export var fly_range: float = 300.0
@export var aoe_radius: float = 50.0
@export var knockback_force: float = 400.0
@export var knockback_time: float = 1.0
@export var package_scene: PackedScene
