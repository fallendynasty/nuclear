class_name RunningState extends State

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	var input_dir := Input.get_vector(player.INPUT_LEFT, player.INPUT_RIGHT, player.INPUT_FORWARD, player.INPUT_BACKWARD)
	var move_dir := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if move_dir:
		player.velocity.x = move_dir.x * player.MOVE_SPEED
		player.velocity.z = move_dir.z * player.MOVE_SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.MOVE_SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0, player.MOVE_SPEED)
	player.move_and_slide()

	if not player.is_on_floor():
		finished.emit("FallingState")
	elif Input.is_action_just_pressed(player.INPUT_JUMP):
		finished.emit("JumpingState")
	elif input_dir.length() > 0:
		finished.emit("RunningState")
	elif input_dir.length() == 0:
		finished.emit("IdleState")

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	prints("[RunningState] Running State Entered")

## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	prints("[RunningState] Running State Exited")
