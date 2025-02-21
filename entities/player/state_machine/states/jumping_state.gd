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
	player.handle_movement(_delta, 0) # air strafing

	if player.is_on_wall_only() and Input.is_action_just_pressed(player.INPUT_JUMP):
		finished.emit("WallJumpingState")

	# player is jumping if going upwards, falling if going downwards
	if player.velocity.y < 0:
		finished.emit("FallingState")

## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y += player.JUMP_VELOCITY
	prints("[JumpingState] Jumping State Entered")

## Called by the state machine before changing the active state. Use this function to clean up the state.
func exit() -> void:
	prints("[JumpingState] Jumping State Exited")
