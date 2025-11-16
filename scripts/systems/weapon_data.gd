@tool
extends Resource
class_name WeaponData

@export var weapon_name: String
@export var icon: Texture
@export var attack: int
@export var range: Vector2
@export var attack_speed: int
@export var fly_speed: int
@export var type: String # Blade, Spear, Shuriken, Boomerang
@export_multiline var passive: String
@export_multiline var ultimate: String
@export var cooldown: float
@export var ultimate_attack: int
@export var ultimate_range: Vector2
