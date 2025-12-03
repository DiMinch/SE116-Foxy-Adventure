extends Marker2D
class_name Node2DFactory

signal created(product)

@export var product_packed_scene: PackedScene
@export var target_container_name: StringName
@export var target_container_path: NodePath 

func create(_product_packed_scene := product_packed_scene) -> Node2D:
	var product: Node2D = _product_packed_scene.instantiate()
	product.global_position = global_position
	var container = find_parent("Stage").find_child(target_container_name)
	if container != null:
		container.add_child(product)
		created.emit(product)
		return product
	else:
		print("Lỗi: Không tìm thấy node container tên là: " + target_container_name)
		return null
