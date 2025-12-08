@tool
extends Resource
class_name SkillData

@export var skill_id: StringName
@export var skill_name: String
@export_multiline var description: String
@export var icon: Texture
@export var tier: int = 1
@export var cost: int = 2
@export var type: String = "U" # "U" hoặc "W"
@export var max_level: int = 1
@export var prerequisites: Array = []
@export var default_unlocked: bool = false

@export var weapon_to_unlock: WeaponData

@export_group("Weapon Upgrade")
@export var target_weapon_name: String = ""
@export_group("Weapon DeCooldown(%)")
@export var de_cooldown: float = 1
@export_group("Invulnerable(s)")
@export var invul_bonus: float = 2.5
