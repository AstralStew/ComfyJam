class_name BuildMenu extends Control
const DEBUG_NAME : String = "[b][BuildMenu][/b] "

static var instance : BuildMenu = null


@onready var overlay : Control = $"../DarkOverlay"
@onready var build_button : Control = $"../BuildButton"

static var active : bool = false

@export var default_colour : Color = Color(0.576, 0.784, 0.678)
@export var hover_colour : Color = Color.WHITE

signal build(structure_type)
signal cancel


static func show_build_button(_hex:Hex) -> void:
	instance.build_button.global_position = _hex.global_position
	instance.build_button.visible = true

static func hide_build_button() -> void:
	if active: return
	instance.build_button.visible = false

func _ready() -> void:
	instance = self

static func activate() -> void:
	active = true
	
	# PAUSE TIME
	instance.get_tree().paused = true
	
	instance.visible = true
	instance.overlay.visible = true

static func deactivate() -> void:
	active = false
	instance.visible = false
	instance.overlay.visible = false



static func build_structure(_hex:Hex) -> void:
	if _hex.structure != null:
		print_rich(DEBUG_NAME,"BuildStructure > [color=red] Hex already has structure, cancelling")
		return
	
	instance.global_position = _hex.global_position
	activate()
	show_build_button(_hex)
	
	#var _structure_type = await instance.build
	
	var _result = await on_build_or_cancel()	
	
	# UNPAUSE TIME
	instance.get_tree().paused = false
	await instance.get_tree().process_frame
	
	if _result[0] == instance.build:
		var _structure_type = _result[1][0] as StructureManager.StructureType
		if _structure_type != StructureManager.StructureType.BLANK:
			StructureManager.set_structure(_hex,StructureManager.StructureType.CONSTRUCTION, _structure_type)
	#else:
		#deactivate()
	
	
	deactivate()
	hide_build_button()



func _on_option_mouse_entered(building_name:String) -> void:
	match building_name:
		"Hole":
			Tooltip.show_tooltip("- Forages Nectar or Pollen\n- Requires a Worker to operate","HOLE")
			$Hole.self_modulate = hover_colour
		"Honeycomb":
			Tooltip.show_tooltip("- Stores half a dozen resources\n- Toggle edges to send resource\n- Requires a Worker to operate","HONEYCOMB")
			$Honeycomb.self_modulate = hover_colour
		"Nursery":
			Tooltip.show_tooltip("- Nurtures Larvae with Royal Jelly\n- Requires a Worker to operate","NURSERY")
			$Nursery.self_modulate = hover_colour
		"JellyFactory":
			Tooltip.show_tooltip("- Produces Royal Jelly over time\n- Requires a Worker to operate","JELLY FACTORY")
			$"Jelly Factory".self_modulate = hover_colour
		"Dancepad":
			Tooltip.show_tooltip("- Filters the output of other structures\n- Requires a resource as a filter\n- Requires a Worker to operate","DANCEPAD")
			$Dancepad.self_modulate = hover_colour
		"KissStation":
			Tooltip.show_tooltip("- Increases thickness of Nectar\n- Convert thick Nectar into Honey\n- Requires a Worker to operate","KISS STATION")
			$"Kiss Station".self_modulate = hover_colour

func _on_option_mouse_exited(building_name:String) -> void:
	
	match building_name:
		"Hole":
			Tooltip.hide_tooltip()
			$Hole.self_modulate = default_colour
		"Honeycomb":
			Tooltip.hide_tooltip()
			$Honeycomb.self_modulate = default_colour
		"Nursery":
			Tooltip.hide_tooltip()
			$Nursery.self_modulate = default_colour
		"JellyFactory":
			Tooltip.hide_tooltip()
			$"Jelly Factory".self_modulate = default_colour
		"Dancepad":
			Tooltip.hide_tooltip()
			$Dancepad.self_modulate = default_colour
		"KissStation":
			Tooltip.hide_tooltip()
			$"Kiss Station".self_modulate = default_colour
	
	

func _on_hole_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		print_rich(DEBUG_NAME,"OnHoleGuiInput > LeftClick recieved!")
		build.emit(StructureManager.StructureType.HOLE)

func _on_honeycomb_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		print_rich(DEBUG_NAME,"OnHoneycombGuiInput > LeftClick recieved!")
		build.emit(StructureManager.StructureType.HONEYCOMB)

func _on_nursery_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		print_rich(DEBUG_NAME,"OnNurseryGuiInput > LeftClick recieved!")
		build.emit(StructureManager.StructureType.NURSERY)

func _on_jelly_factory_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		print_rich(DEBUG_NAME,"OnJellyFactoryGuiInput > LeftClick recieved!")
		build.emit(StructureManager.StructureType.JELLY_FACTORY)

func _on_dancepad_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		print_rich(DEBUG_NAME,"OnDancepadGuiInput > LeftClick recieved!")
		#build.emit(StructureManager.StructureType.DANCEPAD)

func _on_kiss_station_factory_gui_input(event: InputEvent) -> void:
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		print_rich(DEBUG_NAME,"OnKissStationGuiInput > LeftClick recieved!")
		build.emit(StructureManager.StructureType.KISS_STATION)


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
