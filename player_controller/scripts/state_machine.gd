class_name StateMachine extends Node

@export var initial_state: State = null
@export var player: Player

# TODO change, just default above to IdleState or something
@onready var state: State = (func get_initial_state() -> State:
	return initial_state if initial_state != null else get_child(0)
).call()


func _ready() -> void:
	if player == null:
		player = owner

	for state_node: State in find_children("*", "State"):
		# jank solution to get player object, will do for now
		prints("[StateMachine] State Node '%s' found" % state_node.name)
		state_node.player = player
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
