class_name JumpingState extends State

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	player.velocity.y -= player.GRAVITY * _delta

	var input_dir := Input.get_vector(player.INPUT_LEFT, player.INPUT_RIGHT, player.INPUT_FORWARD, player.INPUT_BACKWARD)
	var move_dir := (player.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if move_dir:
		player.velocity.x = move_dir.x * player.MOVE_SPEED
		player.velocity.z = move_dir.z * player.MOVE_SPEED
	else:
		player.velocity.x = move_toward(player.velocity.x, 0, player.MOVE_SPEED)
		player.velocity.z = move_toward(player.velocity.z, 0, player.MOVE_SPEED)
	player.move_and_slide()

	# player is jumping if going upwards, falling if going downwards
	if player.velocity.y < 0:
		finished.emit("FallingState")

## Called by the state machine upon changing the active state. The `data` parameter
## is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y += player.JUMP_VELOCITY
	prints("[JumpingState] Jumping State Entered")
	prints("[JumpingState] Jumping with velocity.y:", player.velocity.y)

## Called by the state machine before changing the active state. Use this function
## to clean up the state.
func exit() -> void:
	prints("[JumpingState] Jumping State Exited")
