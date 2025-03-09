## Virtual base class State for all player states
class_name State extends Node

var animation_player: AnimationPlayer
var player: Player

## Emitted when the state finishes and wants to transition to another state.
signal finished(next_state_path: String, data: Dictionary)

## Called by the state machine when receiving unhandled input events.
func handle_input(_event: InputEvent) -> void:
	pass

## Called by the state machine on the engine's main loop tick.
func update(_delta: float) -> void:
	pass

## Called by the state machine on the engine's physics update tick.
func physics_update(_delta: float) -> void:
	pass

## Called by the state machine upon changing the active state. The `data` parameter is a dictionary with arbitrary data the state can use to initialize itself.
func enter(previous_state_path: String, data := {}) -> void:
	pass

## Called by the state machine before changing the active state. Use this function to clean up the state.
func exit() -> void:
	pass

## handling signal 'finished' emission for running and idle 
func handle_grounded_states_signal_emission() -> void: 
	if not player.is_on_floor():
		finished.emit("FallingState")
	elif Input.is_action_just_pressed(player.INPUT_JUMP):
		finished.emit("JumpingState")
