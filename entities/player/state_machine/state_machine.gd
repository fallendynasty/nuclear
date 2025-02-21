class_name StateMachine extends Node

@export var initial_state: State
@export var player: Player
@export var animation_player: AnimationPlayer

@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()

func _ready() -> void:
	assert(
		player != null,
		"[StateMachine] Error in _ready(): expected `player` to be of type `Player` but got `null`. " +
		"Please set the `player` export in the editor."
	)

	assert(
		animation_player != null,
		"[StateMachine] Error in _ready(): expected `animation_player` to be of type `AnimationPlayer` but got `null`. " +
		"Please set the `animation_player` export in the editor."
	)

	for state_node: State in find_children("*", "State"):
		prints("[StateMachine] State Node '%s' found" % state_node.name)
		state_node.player = player
		state_node.animation_player = animation_player
		state_node.finished.connect(_transition_to_next_state)

	await owner.ready
	state.enter("")
	prints("[StateMachine] State Machine Ready")


func _unhandled_input(event: InputEvent) -> void:
	state.handle_input(event)


func _process(delta: float) -> void:
	state.update(delta)


func _physics_process(delta: float) -> void:
	state.physics_update(delta)


func _transition_to_next_state(target_state_path: String, data: Dictionary = {}) -> void:
	if not has_node(target_state_path):
		printerr(owner.name + ": Trying to transition to state " + target_state_path + " but it does not exist.")
		return

	var previous_state_path := state.name
	state.exit()
	state = get_node(target_state_path)
	state.enter(previous_state_path, data)
