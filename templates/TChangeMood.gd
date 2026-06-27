extends Button

@onready var character_display = $"../SCharacterDisplay"
var change_int : int = 0
func _on_pressed() -> void:
	character_display.load_character(preload("res://helper/CResources/Scarffy.tres"))
	if change_int == 0:
		character_display.set_emotion("happy")
	elif change_int == 1:
		character_display.set_emotion("idle")
	elif change_int == 2:
		character_display.set_emotion("disappointed")
	elif change_int == 3:
		character_display.set_emotion("ask")
		change_int = 0
	change_int += 1
