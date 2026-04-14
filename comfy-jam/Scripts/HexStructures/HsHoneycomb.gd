class_name HexStructureHoneycomb extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsHoneycomb][/b] "

var edge_tl : Label = null
var edge_tr : Label = null
var edge_l : Label = null
var edge_r : Label = null
var edge_bl : Label = null
var edge_br : Label = null

var texture : Texture = null

var honeycomb_sprite : Sprite2D = null

@export var cooldown_time : float = 1

@export var speed_multiplier : float = 1

@export var capacity : int = 4

@export var tl_open : bool = false
@export var tr_open : bool = false
@export var l_open : bool = false
@export var r_open : bool = false
@export var bl_open : bool = false
@export var br_open : bool = false

@export_category("READ ONLY")
@export var is_full : bool = false :
	get: return _outputs.size() + (1 if output != null else 0) >= capacity

var cooldowning : bool = false

func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(Honeycomb) > Setting up edges")
	edge_tl = $Edge_tl
	edge_tr = $Edge_tr
	edge_l = $Edge_l
	edge_r = $Edge_r
	edge_bl = $Edge_bl
	edge_br = $Edge_br
	
	set_edge(HexManager.HexDirection.TopL,false)
	set_edge(HexManager.HexDirection.TopR,false)
	set_edge(HexManager.HexDirection.MidL,false)
	set_edge(HexManager.HexDirection.MidR,false)
	set_edge(HexManager.HexDirection.BotL,false)
	set_edge(HexManager.HexDirection.BotR,false)
	
	honeycomb_sprite = $HsHoneycomb
	texture = preload("res://Assets/Images/Structures/HS_Honeycomb.png")
	
	max_workers = 1
	
	#on_output_object_removed.connect(check_adjacent_hexes)
	on_outputs_added.connect(dispense)
	



func toggle_edge(_direction:HexManager.HexDirection) -> void:
	print_rich(DEBUG_NAME,"ToggleEdge > Setting edge '"+str(_direction)+"' to " + ("open" if !get_edge_open(_direction) else "closed"))
	set_edge(_direction,!get_edge_open(_direction))

func set_edge(_direction:HexManager.HexDirection, _open:bool) -> void:
	var _text = ">" if _open else "<"
	var _color = Color(0.525, 0.757, 0.639, 1.0) if _open else  Color(0.655, 0.357, 0.502, 1.0)
	
	match _direction:
		HexManager.HexDirection.TopL:
			tl_open = _open
			edge_tl.text = _text
			edge_tl.modulate = _color
			
		HexManager.HexDirection.TopR:
			tr_open = _open
			edge_tr.text = _text
			edge_tr.modulate = _color
			
		HexManager.HexDirection.MidL:
			l_open = _open
			edge_l.text = _text
			edge_l.modulate = _color
			
		HexManager.HexDirection.MidR:
			r_open = _open
			edge_r.text = _text
			edge_r.modulate = _color
			
		HexManager.HexDirection.BotL:
			bl_open = _open
			edge_bl.text = _text
			edge_bl.modulate = _color
			
		HexManager.HexDirection.BotR:
			br_open = _open
			edge_br.text = _text
			edge_br.modulate = _color
	
	update_adjacent_hexes()

func get_edge_open(_direction:HexManager.HexDirection) -> bool:
	match _direction:
		HexManager.HexDirection.TopL: return tl_open
		HexManager.HexDirection.TopR: return tr_open
		HexManager.HexDirection.MidL: return l_open
		HexManager.HexDirection.MidR: return r_open
		HexManager.HexDirection.BotL: return bl_open
		HexManager.HexDirection.BotR: return br_open
	push_error(DEBUG_NAME,"GetEdgeOpen > [color=red] Bad direction!")
	
	return false


func update_adjacent_hexes() -> void:
	await get_tree().create_timer(adjacent_output_removal_delay).timeout
	#HexManager.get_adjacent_hex(hex,)
	#var _adacent_hexes = HexManager.get_adjacent_hexes(hex)
	var _adjacent_hex : Hex = null
	var _took_object_from_me : bool = false
	
	var _directions = HexManager.HexDirection.values()
	_directions.shuffle()
	for _direction in _directions:
		_adjacent_hex = HexManager.get_adjacent_hex(hex,_direction)
		if _adjacent_hex != null && _adjacent_hex.structure != null:
			#adjacent_hex_updated(_adjacent_hex)
			if !_took_object_from_me && get_edge_open(_direction):
				print_rich(DEBUG_NAME,"UpdateAdjacentHexes > Adjacent hex '"+_adjacent_hex.name+"' is OPEN and has a structure, asking if it wants the object")
				if _adjacent_hex.structure.adjacent_hex_updated(hex):
					print_rich(DEBUG_NAME,"UpdateAdjacentHexes > Adjacent hex '"+_adjacent_hex.name+"' accepted!")
					_took_object_from_me = true
			print_rich(DEBUG_NAME,"UpdateAdjacentHexes > Adjacent hex '"+_adjacent_hex.name+"' said no or that direction is closed")
	
	#
	#var _adacent_hexes = HexManager.get_adjacent_hexes(hex)
	#_adacent_hexes.shuffle()
	#var _took_object_from_me : bool = false
	#for _adjacent_hex:Hex in _adacent_hexes:
		#if _adjacent_hex.structure != null:
			#adjacent_hex_updated(_adjacent_hex)
			#if !_took_object_from_me:
				#print_rich(DEBUG_NAME,"UpdateAdjacentHexes > Adjacent hex '"+_adjacent_hex.name+"' has a structure, asking if it wants the object")
				#if _adjacent_hex.structure.adjacent_hex_updated(hex):
					#print_rich(DEBUG_NAME,"UpdateAdjacentHexes > Adjacent hex '"+_adjacent_hex.name+"' accepted!")
					#_took_object_from_me = true
			#print_rich(DEBUG_NAME,"UpdateAdjacentHexes > Adjacent hex '"+_adjacent_hex.name+"' said no.")



func nectar_dropped_here(_nectar:Nectar) -> bool:
	if !active || is_full:
		return false
	
	#_nectar.queue_free()
	ObjectManager.move_and_destroy(_nectar,hex.global_position)
	add_object_to_output(ObjectManager.ObjectType.NECTAR)
	
	return true

func pollen_dropped_here(_pollen:Pollen) -> bool:
	if !active || is_full:
		return false
	
	#_pollen.queue_free()	
	ObjectManager.move_and_destroy(_pollen,hex.global_position)
	add_object_to_output(ObjectManager.ObjectType.POLLEN)
	
	return true

func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	if !active || is_full:
		print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > No space for RoyalJelly! Returning false")
		return false
	
	#_royal_jelly.queue_free()
	ObjectManager.move_and_destroy(_royal_jelly,hex.global_position)
	add_object_to_output(ObjectManager.ObjectType.ROYAL_JELLY)
	
	return true


func activate() -> void:
	print_rich(DEBUG_NAME,"Activate > Worker assigned, beginning to produce!")
	honeycomb_sprite.texture = texture
	active = true
	
	super()
	
	#dispensing()

func dispense() -> void:
	await get_tree().create_timer(cooldown_time).timeout
	output_object()



func _tl_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		toggle_edge(HexManager.HexDirection.TopL)

func _tr_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		toggle_edge(HexManager.HexDirection.TopR)

func _l_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		toggle_edge(HexManager.HexDirection.MidL)

func _r_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		toggle_edge(HexManager.HexDirection.MidR)

func _bl_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		toggle_edge(HexManager.HexDirection.BotL)

func _br_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		toggle_edge(HexManager.HexDirection.BotR)
