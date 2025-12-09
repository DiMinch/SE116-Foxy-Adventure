@tool
extends WeaponData
class_name ShurikenData

@export var spread_angles: Array[int] = []
@export var effect_bpassive: PackedScene
@export var projectile_scene: PackedScene
@export_group("Passive Boomerang")
@export var attack_passive: int
@export var fly_speed_passive: int
@export var ultidata: UltiData
