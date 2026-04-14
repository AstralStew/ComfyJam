class_name SelectionManager extends Node
const DEBUG_NAME : String = "[b][SelectionManager][/b] "
static var instance : SelectionManager = null

static var has_selection : bool = false :
	get: return current_selection != null

static var current_selection : Node2D = null
static var current_hover : Node2D = null

signal on_selection_change(new_selection)
signal on_hover_change(new_hover)


func _enter_tree() -> void:
	instance = self


static func set_current_selection(_new_selection:Node2D):
	if current_selection == _new_selection:
		print_rich(DEBUG_NAME,"SetCurrentSelection > Same as old selection, ignoring")
		return
	
	# Tell the latest hex we dropped the old object
	if _new_selection == null:
		print_rich(DEBUG_NAME,"SetCurrentSelection > New selection is null, checking for last hovered hex...")
		if HexManager.last_hovered_hex != null:
			print_rich(DEBUG_NAME,"SetCurrentSelection > Telling hex '",HexManager.last_hovered_hex.name,"' that we dropped '",current_selection.name,"'")
			HexManager.last_hovered_hex.object_dropped_here(current_selection)
	
	current_selection = _new_selection
	instance.on_selection_change.emit(_new_selection)

static func set_current_hover(_new_hover:Node2D):
	if current_hover == _new_hover:
		print_rich(DEBUG_NAME,"SetCurrentHover > Same as old hover, ignoring")
		return
	
	current_hover = _new_hover
	instance.on_hover_change.emit(_new_hover)
