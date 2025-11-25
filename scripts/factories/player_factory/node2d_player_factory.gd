extends Marker2D
class_name Node2DPlayerFactory

signal created(product)

@export var product_packed_scene: PackedScene 

@export var target_container_path: NodePath = "." 

func create(_product_packed_scene: PackedScene) -> Node2D:
	if not _product_packed_scene:
		push_warning("Factory Error: Scene to instantiate is missing.")
		return null
		
	var product: Node2D = _product_packed_scene.instantiate()
	product.global_position = global_position

	var container = get_tree().current_scene.get_node_or_null(target_container_path)
	
	if container:
		container.add_child(product)
		created.emit(product)
		return product
	else:
		product.queue_free()
		return null
