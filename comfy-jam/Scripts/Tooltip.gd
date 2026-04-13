class_name Tooltip extends Control
const DEBUG_NAME : String = "[b][Tooltip][/b] "

enum TooltipType {HEX,OBJECT}

static var instance : Tooltip = null

static var max_width : float = 164

@onready var label : RichTextLabel = $Rtl_Tooltip

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if visible:
		global_position = get_global_mouse_position().clamp(
			Vector2.ZERO, 
			Vector2(get_viewport_rect().size.x - (label.size.x),get_viewport_rect().size.y - (label.size.y*2))
			)
		

func _ready() -> void:
	instance = self


static func set_tooltip_type(_type:TooltipType, _element:Variant):
	
	var _tooltip : Array[String] = ["","",""]
	match _type:
		
		TooltipType.HEX:
			print_rich(DEBUG_NAME,"SetTooltipType > Type is an Hex!")
			var _hex = _element as Hex
			if _hex.structure == null:
				if SelectionManager.has_selection:
					BuildMenu.hide_build_button()
					#$BuildButton.visible = false
					Tooltip.hide_tooltip()
					return
				else:
					#$BuildButton.visible = true
					BuildMenu.show_build_button(_element)
					_tooltip[0] = "Build structure"
			elif _hex.structure is HexStructureHole:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is WorkerBee && _hex.structure.assigned_workers == 0:
						_tooltip[0] =  "Assign Worker to Hole"
					else:
						BuildMenu.hide_build_button()
						Tooltip.hide_tooltip()
						return
				else:
					_tooltip[0] =  "- Forages Nectar or Pollen"
					_tooltip[1] = "HOLE"
					if _hex.structure.assigned_workers == 0: _tooltip[2] = "Worker"
				
			elif _hex.structure is HexStructureJellyFactory:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is WorkerBee && _hex.structure.assigned_workers == 0:
						_tooltip[0] =  "Assign Worker to Jelly Factory"
					else:
						BuildMenu.hide_build_button()
						Tooltip.hide_tooltip()
						return
				else:
					_tooltip[0] =  "- Produces Royal Jelly"
					_tooltip[1] = "JELLY FACTORY"
					if _hex.structure.assigned_workers == 0: _tooltip[2] = "Worker"
			elif _hex.structure is HexStructureNursery:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is WorkerBee && _hex.structure.assigned_workers == 0:
						_tooltip[0] =  "Assign Worker to Nursery"
					elif SelectionManager.current_selection is RoyalJelly && !_hex.structure.producing:
						_tooltip[0] =  "Nurture with Royal Jelly"
					else:
						BuildMenu.hide_build_button()
						Tooltip.hide_tooltip()
						return
				else:
					_tooltip[0] =  "- Produces Larvae"
					_tooltip[1] = "NURSERY"
					_tooltip[2] = (
						"Worker" if _hex.structure.assigned_workers == 0 else "" +
						"\n" if _hex.structure.assigned_workers == 0 && !_hex.structure.producing else "" +
						"Royal Jelly" if !_hex.structure.producing else ""
					)
					if _hex.structure.assigned_workers == 0: _tooltip[2] = "Worker"
			elif _hex.structure is HexStructureConstruction:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is WorkerBee && _hex.structure.assigned_workers == 0:
						_tooltip[0] =  "Assign Worker to Construction"
					else:
						BuildMenu.hide_build_button()
						Tooltip.hide_tooltip()
						return
				else:
					_tooltip[0] =  "Building: " + str(StructureManager.StructureType.keys()[_hex.structure.construction_type]).to_lower().capitalize()
					_tooltip[1] = "CONSTRUCTION"
					if _hex.structure.assigned_workers == 0: _tooltip[2] = "Worker"
					elif _hex.structure.inputs.size() > 0:
						for i in _hex.structure.inputs.size():
							if _tooltip[2] != "" || i > 0: _tooltip[2] += "\n"
							_tooltip[2] += str(ObjectManager.ObjectType.keys()[_hex.structure.inputs[i]]).to_lower().capitalize()
						
			
		
		TooltipType.OBJECT:
			print_rich(DEBUG_NAME,"SetTooltipType > Type is an object!")
			if SelectionManager.has_selection:
					print_rich(DEBUG_NAME,"SetTooltipType > SelectionManager has selection, hiding tooltip")
					Tooltip.hide_tooltip()
					return
			
			if _element is WorkerBee:
				print_rich(DEBUG_NAME,"SetTooltipType > Element is WorkerBee!")
				_tooltip[0] =  "- Assign to structures!"
				_tooltip[1] = "WORKER BEE"
			
			elif _element is Larvae:
				print_rich(DEBUG_NAME,"SetTooltipType > Element is Larvae!")
				_tooltip[0] =  "- Eats food on the floor"
				_tooltip[1] = "LARVAE"
			
			elif _element is Nectar:
				print_rich(DEBUG_NAME,"SetTooltipType > Element is Nectar!")
				_tooltip[0] =  "- Resource for building\n- Eaten by Larvae"
				_tooltip[1] = "NECTAR"
			
			elif _element is Pollen:
				print_rich(DEBUG_NAME,"SetTooltipType > Element is Pollen!")
				_tooltip[0] =  "- Resource for building\n- Eaten by Larvae"
				_tooltip[1] = "POLLEN"
			
			elif _element is RoyalJelly:
				print_rich(DEBUG_NAME,"SetTooltipType > Element is RoyalJelly!")
				_tooltip[0] =  "- Resource for building"
				_tooltip[1] = "ROYAL JELLY"
		
	
	Tooltip.show_tooltip(_tooltip[0],_tooltip[1],_tooltip[2])


static func show_tooltip(_text:String="", _title:String="",_missing:String="") -> void:
	instance.label.text = ""
	#instance.label.size = Vector2(0,0)
	instance.label.reset_size()
	instance.label.text = ("[b]"+_title+"[/b]\n" if _title != "" else "") + _text + ("\n[color=a60050][b]* Missing:[/b] "+_missing if _missing != "" else "")
	
	if instance.label.size.x > max_width:
		instance.label.size.x = max_width
	
	instance.visible = true

static func hide_tooltip() -> void:
	instance.visible = false
