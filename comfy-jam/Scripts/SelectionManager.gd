class_name SelectionManager extends Node
const DEBUG_NAME : String = "[b][SelectionManager][/b] "
static var instance : SelectionManager = null

static var has_selection : bool = false :
	get: return current_selection != null

static var current_selection : Node2D = null :
	get: return current_selection
	set(value):
		if current_selection != value:
			instance.on_selection_change.emit(value)
		current_selection = value

signal on_selection_change(new_selection)


func _enter_tree() -> void:
	instance = self
