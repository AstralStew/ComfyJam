class_name BuildMenu extends Control
const DEBUG_NAME : String = "[b][BuildMenu][/b] "

signal build(structure_type)

@onready var overlay : Control = $"../DarkOverlay"


func activate() -> void:
	visible = true
	overlay.visible = true

func deactivate() -> void:
	visible = false
	overlay.visible = false



func build_structure(_hex:Hex) -> void:
	if _hex.structure != null:
		print_rich(DEBUG_NAME,"BuildStructure > [color=red] Hex already has structure, cancelling")
		return
	
	global_position = _hex.global_position
	activate()
	
	var _structure_type = await build
	if _structure_type != StructureManager.StructureType.BLANK:
		StructureManager.set_structure(_hex,_structure_type)
	
	deactivate()




func _on_l_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("Click"):
		print_rich(DEBUG_NAME,"OnLGuiInput > Mouse click recieved!")
		build.emit(StructureManager.StructureType.NURSERY)

func _on_r_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("Click"):
		print_rich(DEBUG_NAME,"OnRGuiInput > Mouse click recieved!")
		build.emit(StructureManager.StructureType.JELLY_FACTORY)
