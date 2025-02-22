extends Control

@export var player: Player
var is_open: bool = false

func _ready() -> void:
	close()

func _process(delta: float) -> void:
	if Input.is_action_just_pressed(player.INPUT_INVENTORY):
		if is_open:
			close()
			Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
		else:
			open()
			Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
			
func open():
	self.visible = true
	is_open = true
	
func close():
	self.visible = false
	is_open = false
