extends TextureRect
class_name FallingTopping

var gravity: float = 1800.0
var rotation_speed: float = 0.0
## Y (in the parent's local space) this node's top-left should stop falling at.
var target_y: float = 0.0

var _velocity_y: float = 0.0
var _landed: bool = false


func _process(delta: float) -> void:
	if _landed:
		return
	_velocity_y += gravity * delta
	position.y += _velocity_y * delta
	rotation += rotation_speed * delta
	if position.y >= target_y:
		position.y = target_y
		_landed = true
		set_process(false)
