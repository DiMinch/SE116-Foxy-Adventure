extends Node
class_name InvetorySystem

signal item_changed(item_type: String, new_amount: int)

# Currency Items
var currencies := {
	"coins": 0,
	"keys": 0
}
# Powerup Items
var consumables := {
	"fruits": 0
}

func _ready() -> void:
	pass

func add_currency(type: String, amount: int = 1) -> void:
	if not currencies.has(type):
		push_warning("Unknown currency: %s" % type)
		return
	
	currencies[type] += amount
	item_changed.emit(type, currencies[type])

func get_currency(type: String) -> int:
	return currencies.get(type, 0)

func use_currency(type: String, amount: int) -> bool:
	if currencies[type] < amount:
		return false
	
	currencies[type] -= amount
	item_changed.emit(type, currencies[type])
	return true

func add_consumable(type: String, amount: int = 1) -> void:
	if not consumables.has(type):
		push_warning("Unknown consumable: %s" % type)
		return
	
	consumables[type] += amount
	item_changed.emit(type, amount)

func use_consumable(type: String, amount: int = 1) -> bool:
	if consumables.get(type, 0) < amount:
		return false
	
	consumables[type] -= amount
	item_changed.emit(type, consumables[type])
	return true

func has_key() -> bool:
	return currencies.keys > 0

func reset_level_inventory():
	if currencies.has("coins"):
		currencies["coins"] = 0
		item_changed.emit("coins", 0)
	if currencies.has("keys"):
		currencies["keys"] = 0
		item_changed.emit("keys", 0)
	if consumables.has("fruits"):
		consumables["fruits"] = 0
		item_changed.emit("fruits", 0)
