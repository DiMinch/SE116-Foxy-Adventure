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
	debug("add", type, amount)

func get_currency(type: String) -> int:
	return currencies.get(type, 0)

func use_currency(type: String, amount: int) -> bool:
	if currencies[type] < amount:
		return false
	
	currencies[type] -= amount
	item_changed.emit(type, currencies[type])
	debug("use", type, amount)
	return true

func add_consumable(type: String, amount: int = 1) -> void:
	if not consumables.has(type):
		push_warning("Unknown consumable: %s" % type)
		return
	
	consumables[type] += amount
	item_changed.emit(type, amount)
	debug("add", type, amount)

func use_consumable(type: String, amount: int = 1) -> bool:
	if consumables.get(type, 0) < amount:
		return false
	
	consumables[type] -= amount
	item_changed.emit(type, consumables[type])
	debug("use", type, amount)
	return true

func has_key() -> bool:
	return currencies.keys > 0

func reset_level_coins():
	if currencies.has("coins"):
		currencies["coins"] = 0
		item_changed.emit("coins", 0)
		print("[INVENTORY] Level Coins cleared.")

func debug(debug_type: String, item_type: String, amount: int) -> void:
	var current_amount = 0
	if item_type == "fruits":
		current_amount = consumables[item_type]
	else:
		current_amount = currencies[item_type]
	
	if debug_type == "add":
		print("[INVENTORY] Collected %d %s. Total: %d" % [amount, item_type, current_amount])
	if debug_type == "use":
		print("[INVENTORY] Used %d %s. Remainder: %d" % [amount, item_type, current_amount])
