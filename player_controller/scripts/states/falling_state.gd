class_name FallingState extends State

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	player.velocity.y -= player.GRAVITY * _delta
	super.handle_movement() # handle air movements (air strafing and stuff)

	if player.velocity.y == 0: # player on floor, check velocity => idle or running
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
	prints("[FallingState] Falling State Exited")
