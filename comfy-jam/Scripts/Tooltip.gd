class_name Tooltip extends Control
const DEBUG_NAME : String = "[b][Tooltip][/b] "
@export var debug : bool = false

enum TooltipType {HEX,OBJECT}

static var instance : Tooltip = null

static var max_width : float = 164

@onready var label : RichTextLabel = $Rtl_Tooltip

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if visible:
		global_position = get_global_mouse_position() .clamp(
			Vector2.ZERO, 
			Vector2(get_viewport_rect().size.x - (label.size.x*1.33),get_viewport_rect().size.y - (label.size.y*2))
			)
		
		#if global_position.x < get_viewport_rect().size.x / 2:
			#(get_child(0) as RichTextLabel).set_anchors_preset(Control.PRESET_TOP_LEFT,true)
			#(get_child(0) as RichTextLabel).horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
			#get_child(0).position.x = 24.0
		#else:
			#(get_child(0) as RichTextLabel).set_anchors_preset(Control.PRESET_TOP_RIGHT,true)
			#(get_child(0) as RichTextLabel).horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
			#get_child(0).position.x = -156

func _ready() -> void:
	instance = self


static func set_tooltip_type(_type:TooltipType, _element:Variant):
	
	
	if instance.debug: print_rich(DEBUG_NAME,"SetTooltipType > [color=orange] _type = ",str(_type),str(_element))
	
	var _tooltip : Array = ["",""]
	_tooltip.append([] as Array[ObjectManager.ObjectType])
	#_tooltip[2] = [ObjectManager.ObjectType.LARVAE]
	match _type:
		
		TooltipType.HEX:
			if instance.debug: print_rich(DEBUG_NAME,"SetTooltipType > Type is an Hex!")
			var _hex = _element as Hex
			
			## -- EMPTY HEX -------------------------------------
			
			if _hex.structure == null:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is WorkerBee:
						#BuildMenu.show_build_button(_element)
						_tooltip[0] = "Build new structure"
					else:
						#BuildMenu.hide_build_button()
						Tooltip.hide_tooltip()
						return
				else:
					#BuildMenu.hide_build_button()
					Tooltip.hide_tooltip()
					return
			
			## -- HOLE -------------------------------------
			
			elif _hex.structure is HexStructureHole:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is WorkerBee && _hex.structure.assigned_workers == 0:
						_tooltip[0] =  "Assign Worker to Hole"
					else:
						#BuildMenu.hide_build_button()
						Tooltip.hide_tooltip()
						return
				else:
					_tooltip[0] =  "- Forages Nectar or Pollen"
					_tooltip[1] = "HOLE"
					_tooltip[2] = _hex.structure.get_missing_objects()
			
		## -- JELLY FACTORY -------------------------------------
			
			elif _hex.structure is HexStructureJellyFactory:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is WorkerBee && _hex.structure.assigned_workers == 0:
						_tooltip[0] =  "Assign Worker to Jelly Factory"
					else:
						#BuildMenu.hide_build_button()
						Tooltip.hide_tooltip()
						return
				else:
					_tooltip[0] =  "- Produces Royal Jelly"
					_tooltip[1] = "JELLY FACTORY"
					_tooltip[2] = _hex.structure.get_missing_objects()
			
			## -- NURSERY -------------------------------------
			
			elif _hex.structure is HexStructureNursery:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is WorkerBee && _hex.structure.assigned_workers == 0:
						_tooltip[0] =  "Assign Worker to Nursery"
					elif SelectionManager.current_selection is RoyalJelly && !_hex.structure.nurturing:
						_tooltip[0] =  "Nurture with Royal Jelly"
					else:
						#BuildMenu.hide_build_button()
						Tooltip.hide_tooltip()
						return
				else:
					_tooltip[0] =  "- Produces Larvae"
					_tooltip[1] = "NURSERY"
					_tooltip[2] = _hex.structure.get_missing_objects()
			
			## -- CONSTRUCTION -------------------------------------
			
			elif _hex.structure is HexStructureConstruction:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is WorkerBee && _hex.structure.assigned_workers == 0:
						_tooltip[0] =  "Assign Worker to Construction"
					elif _hex.structure.inputs.size() > 0:
						print_rich("[color=teal] Input = " + str(_hex.structure.inputs))
						for i in _hex.structure.inputs.size():
							if _hex.structure.inputs[i] == ObjectManager.get_type_of_object(SelectionManager.current_selection):
								_tooltip[0] = "Pitch in " + str(ObjectManager.ObjectType.keys()[_hex.structure.inputs[i]]).to_lower().capitalize()
								break
						if _tooltip[0] == "":
							#BuildMenu.hide_build_button()
							Tooltip.hide_tooltip()
							return
					else:
						#BuildMenu.hide_build_button()
						Tooltip.hide_tooltip()
						return
					
				else:
					_tooltip[0] =  "Building: " + str(StructureManager.StructureType.keys()[_hex.structure.construction_type]).to_lower().capitalize()
					_tooltip[1] = "CONSTRUCTION"
					_tooltip[2] = _hex.structure.get_missing_objects()
			
			## -- HONEYCOMB -------------------------------------
			
			elif _hex.structure is HexStructureHoneycomb:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is WorkerBee && _hex.structure.assigned_workers == 0:
						_tooltip[0] =  "Assign Worker to Honeycomb"
					elif SelectionManager.current_selection is Nectar && !_hex.structure.is_full:
						_tooltip[0] =  "Store Nectar"
					elif SelectionManager.current_selection is Pollen && !_hex.structure.is_full:
						_tooltip[0] =  "Store Pollen"
					elif SelectionManager.current_selection is RoyalJelly && !_hex.structure.is_full:
						_tooltip[0] =  "Store Royal Jelly"
					else:
						#BuildMenu.hide_build_button()
						Tooltip.hide_tooltip()
						return
				else:
					_tooltip[0] =  "- Stores resources\n- Click arrows to reverse direction"
					if _hex.structure.output != null || _hex.structure._outputs.size() > 0:
						_tooltip[0] += "\n [b]Stored:[/b]"
						if _hex.structure.output != null:
							if _hex.structure.output is Nectar: _tooltip[0] += "\n  * Nectar"
							elif _hex.structure.output is Pollen: _tooltip[0] += "\n  * Pollen"
							elif _hex.structure.output is RoyalJelly: _tooltip[0] += "\n  * Royal Jelly"
						if  _hex.structure._outputs.size() > 0:
							for i in _hex.structure._outputs.size():
								_tooltip[0] += "\n  * " + str(ObjectManager.ObjectType.keys()[_hex.structure._outputs[i]]).to_lower().capitalize()
					
					_tooltip[1] = "HONEYCOMB"
					_tooltip[2] = _hex.structure.get_missing_objects()
			
			## -- IMPASSABLE -------------------------------------
			
			elif _hex.structure is HexStructureImpassable:
				if SelectionManager.has_selection:
					#BuildMenu.hide_build_button()
					Tooltip.hide_tooltip()
					return
				else:
					#_tooltip[0] =  "- Cannot be built on (yet)"
					_tooltip[1] = "IMPASSABLE"
			
			## -- KISS STATION -------------------------------------
			
			elif _hex.structure is HexStructureKissStation:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is WorkerBee && _hex.structure.assigned_workers == 0:
						_tooltip[0] =  "Assign Worker to Kiss Station"
					elif SelectionManager.current_selection is Nectar && !_hex.structure.kissing:
						_tooltip[0] =  "Start kissing this Nectar"
					else:
						#BuildMenu.hide_build_button()
						Tooltip.hide_tooltip()
						return
				else:
					_tooltip[0] = "Converts Nectar into Honey\n  over a few cycles"
					if _hex.structure.kissing_cooldowning: _tooltip[0] += "\n~ cooling down ~"
					_tooltip[1] = "KISS STATION"
					_tooltip[2] = _hex.structure.get_missing_objects()
			
			## -- ROYAL CHAMBER -------------------------------------
			
			elif _hex.structure is HexStructureDancepad:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is WorkerBee && _hex.structure.assigned_workers == 0:
						_tooltip[0] =  "Assign Worker to Dancepad"
					elif SelectionManager.current_selection is Nectar && !_hex.structure.filter!=ObjectManager.ObjectType.NECTAR:
						_tooltip[0] =  "Filter for Nectar"
					elif SelectionManager.current_selection is Pollen && !_hex.structure.filter!=ObjectManager.ObjectType.POLLEN:
						_tooltip[0] =  "Filter for Pollen"
					elif SelectionManager.current_selection is RoyalJelly && !_hex.structure.filter!=ObjectManager.ObjectType.ROYAL_JELLY:
						_tooltip[0] =  "Filter for Royal Jelly"
					elif SelectionManager.current_selection is Honey && !_hex.structure.filter!=ObjectManager.ObjectType.HONEY:
						_tooltip[0] =  "Filter for Honey"
					elif SelectionManager.current_selection is Larvae && !_hex.structure.filter!=ObjectManager.ObjectType.LARVAE:
						_tooltip[0] =  "Filter for Larvae"
					else:
						Tooltip.hide_tooltip()
						return
				else:
					
					if _hex.structure.filter_active:
						_tooltip[0] = "[b]Filtering:[/b][color=a60050] " + str(ObjectManager.ObjectType.keys()[_hex.structure.filter]).to_lower().capitalize()
					else:
						_tooltip[0] = "[color=a60050][b]Drag object here to set filter[/b]"
					_tooltip[0] +=  "[/color]\n- Filters out resources\n- Click dots to set direction"
					_tooltip[1] = "DANCEPAD"
					_tooltip[2] = _hex.structure.get_missing_objects()
			
			## -- ROYAL CHAMBER -------------------------------------
			
			elif _hex.structure is HexStructureRoyalChambers:
				if SelectionManager.has_selection:
					if SelectionManager.current_selection is Honey:
						_tooltip[0] = "Begin loading up Honey for\n the new Queen's journey...\n[color=a60050][b]Warning:[/b][/color] You only have\n a minute to load up more!"
					
					#if _hex.structure.order_recipe.size() > 0:
						#for i in _hex.structure.order_recipe.size():
							#if _hex.structure.order_recipe[i] == ObjectManager.get_type_of_object(SelectionManager.current_selection):
								#_tooltip[0] = "Offer the " + str(ObjectManager.ObjectType.keys()[_hex.structure.order_recipe[i]]).to_lower().capitalize()
								#break
						#if _tooltip[0] == "":
							##BuildMenu.hide_build_button()
							#Tooltip.hide_tooltip()
							#return
					else:
						#BuildMenu.hide_build_button()
						Tooltip.hide_tooltip()
						return
				else:
					if _hex.structure.countdowning: _tooltip[0] = "[color=a60050][b]Less than a minute to feed queen![/b][/color]"
					else: _tooltip[0] = "[color=a60050]~lil queen sounds~[/color]"
					_tooltip[0] +=  "\n- Can only be fed via hexes\n   (cannot be fed via mouse)"
					_tooltip[1] = "ROYAL CHAMBERS"
					_tooltip[2] = _hex.structure.get_missing_objects()
		
		
		TooltipType.OBJECT:
			if instance.debug: print_rich(DEBUG_NAME,"SetTooltipType > Type is an object!")
			if SelectionManager.has_selection:
					if instance.debug: print_rich(DEBUG_NAME,"SetTooltipType > SelectionManager has selection, hiding tooltip")
					Tooltip.hide_tooltip()
					return
			
			if _element is WorkerBee:
				if instance.debug: print_rich(DEBUG_NAME,"SetTooltipType > Element is WorkerBee!")
				_tooltip[0] =  "- Assign to structures!"
				_tooltip[1] = "WORKER BEE"
			
			elif _element is Larvae:
				if instance.debug: print_rich(DEBUG_NAME,"SetTooltipType > Element is Larvae!")
				_tooltip[0] =  "- Eats food on the floor"
				_tooltip[1] = "LARVAE"
			
			elif _element is Nectar:
				if instance.debug: print_rich(DEBUG_NAME,"SetTooltipType > Element is Nectar!")
				_tooltip[0] =  "- Resource for building\n- Eaten by Larvae"
				if _element.kissed_level != Nectar.KissLevel.UNKISSED:
					_tooltip[0] += "\n [color=a75b80][b]Kiss Level:[/b] " + str(Nectar.KissLevel.keys()[_element.kissed_level]).to_lower().capitalize() +"[/color]"
				_tooltip[1] = "NECTAR"
			
			elif _element is Pollen:
				if instance.debug: print_rich(DEBUG_NAME,"SetTooltipType > Element is Pollen!")
				_tooltip[0] =  "- Resource for building\n- Eaten by Larvae"
				_tooltip[1] = "POLLEN"
			
			elif _element is RoyalJelly:
				if instance.debug: print_rich(DEBUG_NAME,"SetTooltipType > Element is RoyalJelly!")
				_tooltip[0] =  "- Resource for building"
				_tooltip[1] = "ROYAL JELLY"
			
			elif _element is Honey:
				if instance.debug: print_rich(DEBUG_NAME,"SetTooltipType > Element is Honey!")
				_tooltip[0] =  "- Resource for building"
				_tooltip[1] = "HONEY"
	
	
	if instance.debug: print_rich(DEBUG_NAME,"SetTooltipType > Final texts = '"+_tooltip[0]+"', '"+_tooltip[1]+"', '"+str(_tooltip[2]))
	
	Tooltip.show_tooltip(_tooltip[0],_tooltip[1],_tooltip[2])


static func show_tooltip(_text:String="", _title:String="",_missing:Array=[]) -> void:
	if instance.debug: print_rich(DEBUG_NAME,"ShowTooltip > Texts = '"+_text+"', '"+_title+"', ' "+str(_missing)+" '")
	instance.label.text = ""
	#instance.label.size = Vector2(0,0)
	instance.label.reset_size()
	await instance.get_tree().process_frame
	instance.label.text = ("[b]"+_title+"[/b]\n" if _title != "" else "")
	instance.label.text += _text 
	if _missing.size() > 0:
		instance.label.text += "\n[color=a60050][b]Missing:[/b]"
		for i in _missing.size():
			instance.label.text += "\n[color=a60050] * " + str(ObjectManager.ObjectType.keys()[_missing[i]]).to_lower().capitalize()
	
	if instance.label.size.x > max_width:
		instance.label.size.x = max_width
	
	instance.visible = true

static func hide_tooltip() -> void:
	instance.visible = false
