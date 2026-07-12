extends Control

@onready var stand: IceCreamStand = $Stand


func _ready() -> void:
	for item in _find_draggable_items(self):
		item.topping_clicked.connect(_on_topping_clicked)


func _on_topping_clicked(data: Dictionary) -> void:
	stand.arm_topping(data)


func _find_draggable_items(node: Node) -> Array:
	var result: Array = []
	for child in node.get_children():
		if child is DraggableItem:
			result.append(child)
		result.append_array(_find_draggable_items(child))
	return result
