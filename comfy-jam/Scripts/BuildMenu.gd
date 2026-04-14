class_name BuildMenu extends Control
const DEBUG_NAME : String = "[b][BuildMenu][/b] "

static var instance : BuildMenu = null


@onready var overlay : Control = $"../DarkOverlay"
@onready var build_button : Control = $"../BuildButton"


signal build(structure_type)
signal cancel


static func show_build_button(_hex:Hex) -> void:
	instance.build_button.global_position = _hex.global_position
	instance.build_button.visible = true

static func hide_build_button() -> void:
	instance.build_button.visible = false

func _ready() -> void:
	instance = self

static func activate() -> void:
	instance.visible = true
	instance.overlay.visible = true

static func deactivate() -> void:
	instance.visible = false
	instance.overlay.visible = false



static func build_structure(_hex:Hex) -> void:
	if _hex.structure != null:
		print_rich(DEBUG_NAME,"BuildStructure > [color=red] Hex already has structure, cancelling")
		return
	
	instance.global_position = _hex.global_position
	activate()
	
	#var _structure_type = await instance.build
	
	var _result = await on_build_or_cancel()
	if _result[0] == instance.build:
		var _structure_type = _result[1][0] as StructureManager.StructureType
		if _structure_type != StructureManager.StructureType.BLANK:
			StructureManager.set_structure(_hex,StructureManager.StructureType.CONSTRUCTION, _structure_type)
	else:
		deactivate()
	
	
	

	
	deactivate()



func _on_tl_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		print_rich(DEBUG_NAME,"OnTLGuiInput > LeftClick recieved!")
		build.emit(StructureManager.StructureType.HOLE)

func _on_tr_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		print_rich(DEBUG_NAME,"OnTRGuiInput > LeftClick recieved!")
		build.emit(StructureManager.StructureType.HONEYCOMB)

func _on_l_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		print_rich(DEBUG_NAME,"OnLGuiInput > LeftClick recieved!")
		build.emit(StructureManager.StructureType.NURSERY)

func _on_r_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		print_rich(DEBUG_NAME,"OnRGuiInput > LeftClick recieved!")
		build.emit(StructureManager.StructureType.JELLY_FACTORY)


func _on_overlay_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		cancel.emit()
		deactivate()




static func on_build_or_cancel() -> Signal:
	
	var refcounted = RefCounted.new()
	refcounted.add_user_signal("result")
		
	for _signal in [instance.build,instance.cancel]:
		_signal.connect(
			func(...params):
				refcounted.emit_signal("result",_signal,params),
				CONNECT_ONE_SHOT
		)
	
	return Signal(refcounted, "result")
