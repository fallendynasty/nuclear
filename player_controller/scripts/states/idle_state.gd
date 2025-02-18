class_name IdleState extends State

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	# NOTE: since we are on the floor, we can ignore gravity
	super.handle_grounded_states_signal_emission()

	if Input.get_vector(player.INPUT_LEFT, player.INPUT_RIGHT, player.INPUT_FORWARD, player.INPUT_BACKWARD).length() > 0:
		finished.emit("RunningState")	

	# slide forward if idle but slide pressed
	if Input.is_action_just_pressed(player.INPUT_SLIDE):
		finished.emit("SlidingState")

## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	prints("[IdleState] Idle State Entered")

## Called by the state machine before changing the active state. Use this function to clean up the state.
func exit() -> void:
	prints("[IdleState] Idle State Exited")
