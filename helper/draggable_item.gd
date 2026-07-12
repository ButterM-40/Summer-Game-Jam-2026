extends Panel
class_name DraggableItem

signal topping_clicked(data: Dictionary)

enum ItemType { BASE, SCOOP, TOPPING }

@export var item_type: ItemType = ItemType.BASE
@export var item_id: String = ""
@export var texture: Texture2D:
	set(value):
		texture = value
		if icon:
			icon.texture = value
## Must match the scale IceCreamStand applies to this item type, so the drag
## preview is the same size/position as where it will actually land.
@export var display_scale: float = 1.0
## Toppings normally nestle into the seam between overlapping ice cream
## pieces (see IceCreamStand.topping_valley_bias). Enable this for toppings
## that should instead always sit right on the very top, like a cherry.
@export var lands_on_peak: bool = false

@onready var icon: TextureRect = $Icon


func _ready() -> void:
	icon.texture = texture


func _gui_input(event: InputEvent) -> void:
	if item_type != ItemType.TOPPING:
		return
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT and event.pressed:
		topping_clicked.emit({
			"type": item_type,
			"id": item_id,
			"texture": texture,
			"lands_on_peak": lands_on_peak,
		})


## Base and scoop pieces are still placed via classic drag-and-drop. The
## preview is centered on the cursor at full display scale, matching exactly
## how IceCreamStand centers the piece on the drop point.
func _get_drag_data(_at_position: Vector2) -> Variant:
	if item_type == ItemType.TOPPING:
		return null

	var preview_size: Vector2 = texture.get_size() * display_scale
	var preview := TextureRect.new()
	preview.texture = texture
	preview.size = preview_size
	preview.position = -preview_size / 2.0
	preview.modulate.a = 0.85
	preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var wrapper := Control.new()
	wrapper.mouse_filter = Control.MOUSE_FILTER_IGNORE
	wrapper.add_child(preview)
	set_drag_preview(wrapper)

	return {
		"type": item_type,
		"id": item_id,
		"texture": texture,
	}
