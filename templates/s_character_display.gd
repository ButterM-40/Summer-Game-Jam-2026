extends Control

var display: TextureRect
var anim: AnimationPlayer
var current_character: CharacterData

func _ready() -> void:
	anim = $AnimationPlayer
	display = $TextureRect

func load_character(data: CharacterData) -> void:
	current_character = data
	display.texture = data.idle

func set_emotion(emotion: String) -> void:
	match emotion:
		"idle": display.texture = current_character.idle
		"ask":  display.texture = current_character.ask
		"happy": display.texture = current_character.happy
		"disappointed": display.texture = current_character.disappointed


#character_display.load_character(preload("res://characters/Scarffy.tres"))
