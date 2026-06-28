extends CanvasLayer

const CHAR_READ_RATE = 0.04
var tween: Tween

@onready var textbox_container = $TextBoxContainer
@onready var label = $TextBoxContainer/MarginContainer/HBoxContainer/Label

enum State {
	READY,
	READING,
	FINISHED
}

var current_state = State.READY
var text_queue = []

func _ready():
	print("Starting state: State.READY")
	hideTextbox()
	queue_text("[Text Here!]")
	queue_text("Oh shit wait, that ain't right.")
	queue_text("Am I in the right place?")
	queue_text("This IS the main game right?")
	queue_text("I didn't make my way to the demo on accident did I?")

func _process(_delta):
	match current_state:
		State.READY:
			if !text_queue.is_empty():
				displayText()
		State.READING:
			if Input.is_action_just_pressed("ui_accept"):
				label.visible_ratio = 1
				tween.stop()
				changeState(State.FINISHED)
		State.FINISHED:
			if Input.is_action_just_pressed("ui_accept"):
				changeState(State.READY)
				if text_queue.is_empty():
					hideTextbox()

func queue_text(next_text):
	text_queue.push_back(next_text) 

func hideTextbox():
	label.text = ""
	textbox_container.hide()

func showTextbox():
	textbox_container.show()

func displayText():
	var next_text = text_queue.pop_front()
	label.text = next_text
	label.visible_ratio = 0
	changeState(State.READING)
	showTextbox()
	tween = create_tween()
	tween.set_trans(Tween.TRANS_LINEAR)
	tween.tween_property(label, "visible_characters", next_text.length(), next_text.length() * CHAR_READ_RATE)
	tween.tween_callback(on_tween_finished)

func on_tween_finished():
	changeState(State.FINISHED)

func changeState(next_state):
	current_state = next_state
	match current_state:
		State.READY:
			print("Changing state to State.READY")
		State.READING:
			print("Changing state to State.READING")
		State.FINISHED:
			print("Changing state to State.FINISHED")
