class_name FallingState extends State

var is_slide_buffered: bool = false

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

func _buffer_slide() -> void:	
	if Input.is_action_just_pressed(player.INPUT_SLIDE):
		is_slide_buffered = true
	elif Input.is_action_just_released(player.INPUT_SLIDE):
		is_slide_buffered = false

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	player.velocity.y -= player.GRAVITY * _delta
	super.handle_movement(_delta, 0) # handle air movements (air strafing and stuff)

	_buffer_slide()

	if player.velocity.y == 0: # player on floor, check velocity => idle or running
	# if player.is_on_floor():
		if is_slide_buffered:
			finished.emit("SlidingState")
			return

		var horizontal_velocity = Vector2(player.velocity.x, player.velocity.z).length()
		if horizontal_velocity > 0:
			finished.emit("RunningState")
		else:
			finished.emit("IdleState")

## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	prints("[FallingState] Falling State Entered")

## Called by the state machine before changing the active state. Use this function to clean up the state.
func exit() -> void:
	is_slide_buffered = false
	prints("[FallingState] Falling State Exited")
