class_name Draggable extends Area2D
var _debug_name : String :
	get: return "[b][" + get_parent().name + "/Draggable][/b] "

@export var can_drag := false

var hovered = false
var mouse_in = false
var dragging = false



signal on_drag_start
signal on_drag_move
signal on_drag_end

signal on_area_entered(area)

signal on_hover_start
signal on_hover_end

#region Internal functions

func _ready() -> void:
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	if event is InputEventMouseButton:
	
		if event.is_action_pressed("LeftClick"):
			print_rich(_debug_name, "OnInputEvent > LeftClick pressed")
			
			if can_drag && !dragging && !SelectionManager.has_selection && SelectionManager.current_hover == get_parent():
				print_rich(_debug_name, "OnInputEvent > Starting drag...")
				dragging = true
				SelectionManager.set_current_selection(get_parent())
				get_parent().z_index = 2
				on_drag_start.emit()
				wait_for_unclick()
	

func wait_for_unclick() -> void:
	while (dragging):
		await get_tree().process_frame
		if get_tree().paused: continue
		if !Input.is_action_pressed("LeftClick"):
			print_rich(_debug_name, "OnInputEvent > Stopping drag.")
			dragging = false
			SelectionManager.set_current_selection(null)
			get_parent().z_index = 0
			on_drag_end.emit()
		


func _process(delta: float) -> void:
	if dragging:
		if (get_parent() as Node2D).global_position != get_global_mouse_position() - position:
			(get_parent() as Node2D).global_position = get_global_mouse_position() - position
			on_drag_move.emit()


func _on_mouse_entered() -> void:
	hovered = true
	#if SelectionManager.current_hover == null:
	
	if SelectionManager.current_selection != get_parent():
		SelectionManager.set_current_hover(get_parent())
		SelectionManager.instance.on_hover_change.connect(end_hover)
		
		Tooltip.set_tooltip_type(Tooltip.TooltipType.OBJECT,get_parent())
	
	on_hover_start.emit()


func _on_mouse_exited() -> void:
	if hovered:
		if SelectionManager.instance.on_hover_change.is_connected(end_hover):
			SelectionManager.instance.on_hover_change.disconnect(end_hover)
		if SelectionManager.current_hover == get_parent():
			Tooltip.hide_tooltip()
			SelectionManager.set_current_hover(null)
		
		if HexManager.last_hovered_hex != null:
			HexManager.last_hovered_hex._on_mouse_entered()
		
		hovered = false
		on_hover_end.emit()
	

func end_hover(_new_object) -> void:
	if SelectionManager.instance.on_hover_change.is_connected(end_hover):
		SelectionManager.instance.on_hover_change.disconnect(end_hover)
	hovered = false
	on_hover_end.emit()

func _on_area_entered(_area: Area2D) -> void:
	on_area_entered.emit(_area)

#endregion
