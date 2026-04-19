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


@export var edge_open_color = Color(0.525, 0.757, 0.639, 1.0)
@export var edge_closed_color = Color(0.953, 0.71, 0.659, 1.0)


@export_category("READ ONLY")
@export var capacity : int = 4

@export var is_full : bool = false :
	get: return _outputs.size() + (1 if output != null else 0) >= capacity


@export var tl_open : bool = false
@export var tr_open : bool = false
@export var l_open : bool = false
@export var r_open : bool = false
@export var bl_open : bool = false
@export var br_open : bool = false

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
	
	capacity = HiveManager.upgrade_honeycomb_capacity
	
	max_workers = 1
	
	#on_output_object_removed.connect(check_adjacent_hexes)
	on_outputs_added.connect(dispense)
	
	hex.on_hex_hovered.connect(show_edges)
	hex.on_hex_unhovered.connect(hide_edges)
	



func show_edges() -> void:
	edge_tl.visible = true
	edge_tr.visible = true
	edge_l.visible = true
	edge_r.visible = true
	edge_bl.visible = true
	edge_br.visible = true

func hide_edges() -> void:
	if !get_edge_open(HexManager.HexDirection.TopL): edge_tl.visible = false
	if !get_edge_open(HexManager.HexDirection.TopR): edge_tr.visible = false
	if !get_edge_open(HexManager.HexDirection.MidL): edge_l.visible = false
	if !get_edge_open(HexManager.HexDirection.MidR): edge_r.visible = false
	if !get_edge_open(HexManager.HexDirection.BotL): edge_bl.visible = false
	if !get_edge_open(HexManager.HexDirection.BotR): edge_br.visible = false

func toggle_edge(_direction:HexManager.HexDirection) -> void:
	print_rich(DEBUG_NAME,"ToggleEdge > Setting edge '"+str(_direction)+"' to " + ("open" if !get_edge_open(_direction) else "closed"))
	set_edge(_direction,!get_edge_open(_direction))

func set_edge(_direction:HexManager.HexDirection, _open:bool) -> void:
	var _text = ">" if _open else "<"
	var _color = edge_open_color if _open else edge_closed_color
	
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
	
	if !is_waiting_for_output_removed_by_player:
		offer_my_output()
	
	ask_others_to_offer_their_output()
	

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




func offer_my_output() -> void:
	if is_waiting_to_offer_my_output:
		print_rich(DEBUG_NAME,"[color=pink]OfferMyOutput(Honeycomb) > Already waiting to update adjacent hexes, cancelling.")
		return
	if !is_waiting_for_output_removed:
		print_rich(DEBUG_NAME,"[color=pink]OfferMyOutput(Honeycomb) > We aren't even waiting for output to be removed, cancelling.")
		return
	if is_waiting_for_output_removed_by_player:
		print_rich(DEBUG_NAME,"[color=pink]OfferMyOutput(Honeycomb) > Still waiting for output to be removed by player, cancelling")
		return
	
	is_waiting_to_offer_my_output = true
	
	#print_rich(DEBUG_NAME,"[color=pink]OfferMyOutput(Honeycomb) > Waiting for output notify delay...")
	#
	#await get_tree().create_timer(output_notify_delay).timeout
	#
	#
	#if !is_waiting_for_output_removed:
		#print_rich(DEBUG_NAME,"[color=pink]OfferMyOutput(Honeycomb) > We apparently no longer waiting for output to be removed, waiting a frame then flagging that I'm no longer waiting to update adjacent hexes.")
		#await get_tree().process_frame
		#print_rich(DEBUG_NAME,"[color=pink]OfferMyOutput(Honeycomb) > Finished waiting a frame, flagging that I'm no longer waiting to update adjacent hexes.")
		#is_waiting_to_offer_my_output = false
		#return
	#
	#print_rich(DEBUG_NAME,"[color=pink]OfferMyOutput(Honeycomb) > Still waiting for output to be removed!")
	#
	
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
				print_rich(DEBUG_NAME,"OfferMyOutput(Honeycomb) > Adjacent hex '"+_adjacent_hex.name+"' is OPEN and has a structure, asking if it wants the object")
				if _adjacent_hex.structure.adjacent_hex_updated(hex):
					print_rich(DEBUG_NAME,"OfferMyOutput(Honeycomb) > Adjacent hex '"+_adjacent_hex.name+"' accepted!")
					_took_object_from_me = true
				else:
					print_rich(DEBUG_NAME,"OfferMyOutput(Honeycomb) > Adjacent hex '"+_adjacent_hex.name+"' said no or that direction is closed")
	
	await get_tree().process_frame	
	while get_tree().paused:
		await get_tree().process_frame
	
	is_waiting_to_offer_my_output = false


func check_adjacent_hex_is_open(_adjacent_hex:Hex) -> bool:
	
	if HexManager.instance.get_adjacent_coord(hex.coords,HexManager.HexDirection.TopL) == _adjacent_hex.coords:
		return get_edge_open(HexManager.HexDirection.TopL)
	if HexManager.instance.get_adjacent_coord(hex.coords,HexManager.HexDirection.TopR) == _adjacent_hex.coords:
		return get_edge_open(HexManager.HexDirection.TopR)
	if HexManager.instance.get_adjacent_coord(hex.coords,HexManager.HexDirection.MidL) == _adjacent_hex.coords:
		return get_edge_open(HexManager.HexDirection.MidL)
	if HexManager.instance.get_adjacent_coord(hex.coords,HexManager.HexDirection.MidR) == _adjacent_hex.coords:
		return get_edge_open(HexManager.HexDirection.MidR)
	if HexManager.instance.get_adjacent_coord(hex.coords,HexManager.HexDirection.BotL) == _adjacent_hex.coords:
		return get_edge_open(HexManager.HexDirection.BotL)
	if HexManager.instance.get_adjacent_coord(hex.coords,HexManager.HexDirection.BotR) == _adjacent_hex.coords:
		return get_edge_open(HexManager.HexDirection.BotR)
	
	return false


func adjacent_hex_updated(_adjacent_hex:Hex) -> bool:
	print_rich(DEBUG_NAME,"AdjacentHexUpdated(Honeycomb) > Checking adjacent hex '"+_adjacent_hex.name+"'...")
	
	if check_adjacent_hex_is_open(_adjacent_hex):
		print_rich(DEBUG_NAME,"AdjacentHexUpdated(Honeycomb) > Direction of adjacent hex '"+_adjacent_hex.name+"' is open and cannot take objects, returning")
		return false
	
	return super(_adjacent_hex)

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

func honey_dropped_here(_honey:Honey) -> bool:
	if !active || is_full:
		print_rich(DEBUG_NAME,"HoneyDroppedHere > No space for Honey! Returning false")
		return false
	
	ObjectManager.move_and_destroy(_honey,hex.global_position)
	add_object_to_output(ObjectManager.ObjectType.HONEY)
	
	return true

func activate() -> void:
	print_rich(DEBUG_NAME,"Activate > Worker assigned, beginning to produce!")
	honeycomb_sprite.texture = texture
	active = true
	
	super()
	
	#dispensing()


var _dispensing : bool = false
func dispense() -> void:
	if _dispensing || is_waiting_for_output_removed || output_on_cooldown: return
	
	_dispensing = true
	await get_tree().create_timer(cooldown_time).timeout
	output_object()
	_dispensing = false



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


func _on_direction_mouse_entered() -> void:
	hex._on_mouse_entered()

func _on_direction_mouse_exited() -> void:
	hex._on_mouse_exited()
