class_name Hex extends Node2D
var DEBUG_NAME : String  :
	get: return "[b][Hex("+name+")][/b] "

@export var structure : HexStructure = null

@export var coords : Vector2i = Vector2i(-1,-1) :
	get: return coords
	set(value):
		$DebugCoords.text = (" " if value.x >= 0 else "") + str(value.x) + (" " if value.y >= 0 else "") + str(value.y)
		coords = value


signal on_hex_clicked
signal on_hex_unclicked


func object_dropped_here(_object:Node2D) -> void:
	print_rich(DEBUG_NAME,"ObjectDroppedHere > Object = '",_object.name,"'")
	if structure != null:
		structure.object_dropped_here(_object)



# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	
	#if structure != null:
		#on_hex_clicked.connect(structure.clicked)
		#on_hex_unclicked.connect(structure.unclicked)
	
	
	
	if randf() > 0.75: StructureManager.set_structure(self,StructureManager.StructureType.HOLE)


func _on_gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouse:
		
		if event.is_action_pressed("Click"):
			print_rich(DEBUG_NAME,"OnGuiInput > Mouse click recieved!")
			on_hex_clicked.emit()
		
		if event.is_action_released("Click"):
			print_rich(DEBUG_NAME,"OnGuiInput > Mouse released recieved!")
			on_hex_unclicked.emit()


func _on_mouse_entered() -> void:
	if HexManager.last_hovered_hex != self:
		HexManager.last_hovered_hex = self
		$ClickableArea.modulate = Color.WHITE


func _on_mouse_exited() -> void:
	if HexManager.last_hovered_hex == self:
		HexManager.last_hovered_hex = null
		$ClickableArea.modulate = Color.TRANSPARENT
