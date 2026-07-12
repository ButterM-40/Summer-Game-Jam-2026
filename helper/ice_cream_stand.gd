extends Control
class_name IceCreamStand

@export var base_scale: float = 1.15
@export var scoop_scale: float = 1.15
@export var topping_scale: float = 0.7
## Y level (in this control's local space) toppings settle on when they don't land on any ice cream.
@export var floor_y: float = 660.0
@export var topping_gravity: float = 1800.0
## Max spin speed (radians/sec) a falling topping is given, randomized per drop.
@export var topping_spin_speed: float = 6.0
## When a topping's column overlaps more than one ice cream piece, how far it
## sinks from the tallest piece's peak toward its neighbor's top (0 = sits
## right on the peak like before, 1 = sits fully on the neighbor). 0.5 nestles
## it in the seam between the two so it doesn't look like it's floating on
## top of a single scoop.
@export_range(0.0, 1.0) var topping_valley_bias: float = 0.5

var _armed_topping: Dictionary = {}
var _armed_preview: TextureRect = null


func _can_drop_data(_at_position: Vector2, data: Variant) -> bool:
	return typeof(data) == TYPE_DICTIONARY and data.has("type")


func _drop_data(at_position: Vector2, data: Variant) -> void:
	match data["type"]:
		DraggableItem.ItemType.BASE:
			_place_free(data, at_position, base_scale)
		DraggableItem.ItemType.SCOOP:
			_place_free(data, at_position, scoop_scale)


## Selects a topping to follow the cursor; click anywhere on the stand to
## drop it from that exact spot, or right-click to cancel.
func arm_topping(data: Dictionary) -> void:
	_armed_topping = data
	if _armed_preview == null:
		_armed_preview = TextureRect.new()
		_armed_preview.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_armed_preview.modulate.a = 0.85
		add_child(_armed_preview)
	_armed_preview.texture = data["texture"]
	_armed_preview.size = data["texture"].get_size()
	_armed_preview.scale = Vector2(topping_scale, topping_scale)
	_update_armed_preview_position()


func _process(_delta: float) -> void:
	if _armed_preview:
		_update_armed_preview_position()


func _update_armed_preview_position() -> void:
	var scaled_size: Vector2 = _armed_preview.texture.get_size() * topping_scale
	_armed_preview.position = get_local_mouse_position() - scaled_size / 2.0


func _gui_input(event: InputEvent) -> void:
	if _armed_topping.is_empty():
		return
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			var data := _armed_topping
			var drop_point: Vector2 = event.position
			_cancel_armed_topping()
			spawn_falling_topping(data, drop_point)
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			_cancel_armed_topping()


func _cancel_armed_topping() -> void:
	_armed_topping = {}
	if _armed_preview:
		_armed_preview.queue_free()
		_armed_preview = null


func _make_display(data: Dictionary, scale_factor: float) -> TextureRect:
	var display := TextureRect.new()
	display.texture = data["texture"]
	display.size = data["texture"].get_size()
	display.pivot_offset = Vector2.ZERO
	display.scale = Vector2(scale_factor, scale_factor)
	display.mouse_filter = Control.MOUSE_FILTER_IGNORE
	display.set_meta("item_type", data["type"])
	return display


func _place_free(data: Dictionary, at_position: Vector2, scale_factor: float) -> void:
	var display := _make_display(data, scale_factor)
	display.position = at_position - display.texture.get_size() * scale_factor / 2.0
	add_child(display)


## Drops the topping from wherever the cursor released it and lets it fall
## (with a bit of tumble) until it nestles into the seam between the ice
## cream pieces it overlaps (rather than perching on the very top of one, so
## it doesn't look like it's floating), or settles at floor_y (the counter,
## alongside the cone) if it doesn't fall on any ice cream at all.
func spawn_falling_topping(data: Dictionary, start_position: Vector2) -> void:
	var tex: Texture2D = data["texture"]
	var tex_size: Vector2 = tex.get_size()
	var scaled_size: Vector2 = tex_size * topping_scale
	var drop_x: float = clamp(start_position.x, 0.0, size.x)

	var falling := FallingTopping.new()
	falling.texture = tex
	falling.size = tex_size
	falling.pivot_offset = tex_size / 2.0
	falling.scale = Vector2(topping_scale, topping_scale)
	falling.mouse_filter = Control.MOUSE_FILTER_IGNORE
	falling.set_meta("item_type", DraggableItem.ItemType.TOPPING)
	falling.position = Vector2(drop_x, start_position.y) - scaled_size / 2.0
	falling.gravity = topping_gravity
	falling.rotation_speed = randf_range(-topping_spin_speed, topping_spin_speed)
	var use_valley: bool = not data.get("lands_on_peak", false)
	falling.target_y = _surface_y_at(drop_x, use_valley) - scaled_size.y
	add_child(falling)


func _surface_y_at(drop_x: float, use_valley: bool = true) -> float:
	var tops: Array[float] = []
	for child in get_children():
		if child.get_meta("item_type", DraggableItem.ItemType.TOPPING) == DraggableItem.ItemType.TOPPING:
			continue
		var rect := Rect2(child.position, child.texture.get_size() * child.scale)
		if drop_x >= rect.position.x and drop_x <= rect.position.x + rect.size.x:
			tops.append(rect.position.y)

	if tops.is_empty():
		return floor_y

	tops.sort()
	if not use_valley or tops.size() == 1:
		return tops[0]

	return lerp(tops[0], tops[1], topping_valley_bias)
