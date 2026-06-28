extends CPlayerCursor
# Called when the node enters the scene tree for the first time.
@export var CURSOR_ICON: Texture2D = preload("res://assets/alien-pixelated-shape-of-a-digital-game.png")
@export var on_select_cursor: CursorType


func _on_texture_button_pressed() -> void:
	_change_cursor(CURSOR_ICON, on_select_cursor)
	pass # Replace with function body.
