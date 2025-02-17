class_name WallJumpingState extends State

var _frame_count: int = 0

## number of frames for wall jump to last. Cannot move while wall jumping
var _duration_frames: int = 6

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	player.velocity.y -= player.GRAVITY * _delta
	if _frame_count < _duration_frames:
		prints("[WallJumpState] _frame_count =", _frame_count)
		player.move_and_slide()
		_frame_count += 1
		return

	super.handle_movement(_delta, 0) # air strafing

	if player.velocity.y < 0:
		finished.emit("FallingState")
	elif player.velocity.y == 0:
		if player.velocity.length() == 0:
			finished.emit("IdleState")
		else:
			finished.emit("RunningState")

## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	player.velocity.y += player.JUMP_VELOCITY * 0.5
	player.velocity += player.get_wall_normal() * player.JUMP_VELOCITY
	prints("[WallJumpingState] WallJumping State Entered")

## Called by the state machine before changing the active state. Use this function to clean up the state.
func exit() -> void:
	_frame_count = 0
	prints("[WallJumpingState] WallJumping State Exited")
