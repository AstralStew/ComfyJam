class_name Hex extends Node2D
var DEBUG_NAME : String = "[b][Hex("+name+")][/b] "

@export var structure : HexStructure = null

@export var coords : Vector2i = Vector2i(-1,-1) :
	get: return coords
	set(value):
		$DebugCoords.text = (" " if value.x >= 0 else "") + str(value.x) + (" " if value.y >= 0 else "") + str(value.y)
		coords = value


signal hex_clicked


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if randf() > 0.75: StructureManager.set_structure(self,StructureManager.StructureType.HOLE)


func _on_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		print_rich(DEBUG_NAME,"OnGuiInput > Mouse click recieved!")
		hex_clicked.emit()
