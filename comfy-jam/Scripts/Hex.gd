class_name Hex extends Node2D
var DEBUG_NAME : String  :
	get: return "[b][Hex("+name+")][/b] "

@export var structure : HexStructure = null :
	get: return structure
	set(value):
		structure = value
		if value != null:
			structure.hex = self

@export var coords : Vector2i = Vector2i(-1,-1) :
	get: return coords
	set(value):
		$DebugCoords.text = (" " if value.x >= 0 else "") + str(value.x) + (" " if value.y >= 0 else "") + str(value.y)
		coords = value

func get_global_rect() -> Rect2:
	return $ClickableArea.get_global_rect()
	

signal on_hex_clicked
signal on_hex_unclicked

signal on_hex_hovered
signal on_hex_unhovered


func object_dropped_here(_object:Node2D) -> void:
	print_rich(DEBUG_NAME,"ObjectDroppedHere > Object = '",_object.name,"'")
	if structure != null:
		structure.object_dropped_here(_object)





func _on_gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouse:
		
		if event.is_action_pressed("LeftClick"):
			print_rich(DEBUG_NAME,"OnGuiInput > LeftClick pressed recieved!")
			on_hex_clicked.emit()
		
		if event.is_action_released("LeftClick"):
			print_rich(DEBUG_NAME,"OnGuiInput > LeftClick released recieved!")
			on_hex_unclicked.emit()


func _on_mouse_entered() -> void:
	if HexManager.last_hovered_hex != self:
		HexManager.last_hovered_hex = self
		$ClickableArea.modulate = Color(1.0, 1.0, 1.0, 0.239)
		
		Tooltip.set_tooltip_type(Tooltip.TooltipType.HEX,self)
		
		on_hex_hovered.emit()


func _on_mouse_exited() -> void:
	
	if HexManager.last_hovered_hex == self:
		HexManager.last_hovered_hex = null
		
		$ClickableArea.modulate = Color(0.451, 0.176, 0.447, 0.1) #Color.TRANSPARENT
		BuildMenu.hide_build_button()
		
		Tooltip.hide_tooltip()
		
		on_hex_unhovered.emit()
	
	#if !get_global_rect().has_point(get_global_mouse_position()):
