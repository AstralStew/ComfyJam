class_name Draggable extends Area2D
var _debug_name : String :
	get: return "[b][" + get_parent().name + "/Draggable][/b]"

@export var can_drag := false

var hovered = false
var mouse_in = false
var dragging = false



signal on_drag_start
signal on_drag_move
signal on_drag_end

signal on_touching_floor

#region Internal functions

func _unhandled_input(event: InputEvent) -> void:
	if dragging:
		if event is InputEventMouseButton and event.is_action_released("Click"):
			print(_debug_name, " Stopped dragging.")
			dragging = false
			on_drag_end.emit()
		
		if event is InputEventMouseMotion:
			(get_parent() as Node2D).position += event.relative
			on_drag_move.emit()
	

func _on_input_event(viewport: Node, event: InputEvent, shape_idx: int) -> void:
	
	if event is InputEventMouseButton and event.is_action_pressed("Click"):
		
		print(_debug_name, " got input event")
		if !dragging and can_drag:
			print(_debug_name, " Started dragging...")
			dragging=true
			on_drag_start.emit()


func _on_mouse_entered() -> void:
	hovered = true

func _on_mouse_exited() -> void:
	hovered = false


func _on_area_entered(_area: Area2D) -> void:
	if _area.get_parent().is_in_group("Floor"):
		on_touching_floor.emit()

#endregion
