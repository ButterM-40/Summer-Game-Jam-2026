class_name CPlayerCursor
extends Control

# Load the texture from your file system
var Hand = preload("res://icon.svg")
enum CursorType {HAND, SCOOPIC, BASESCOOP, TOPPING, BASEIC}
var CurrentCursor: CursorType = CursorType.HAND

func _ready():
	# Set custom image for the standard arrow shape
	# Vector2 defines the hotspot point of the cursor
	CurrentCursor = CurrentCursor
	Input.set_custom_mouse_cursor(Hand, Input.CURSOR_ARROW, Vector2(0, 0))

func _change_cursor(Icon : Texture2D, SCursorType : CursorType):
	CurrentCursor = SCursorType
	Input.set_custom_mouse_cursor(Icon, Input.CURSOR_ARROW, Vector2(0, 0))
