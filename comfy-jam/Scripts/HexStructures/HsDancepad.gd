class_name HexStructureDancepad extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsDancepad][/b] "

var edge_tl : Label = null
var edge_tr : Label = null
var edge_l : Label = null
var edge_r : Label = null
var edge_bl : Label = null
var edge_br : Label = null

var texture : Texture = null

var dancepad_sprite : Sprite2D = null

@export var cooldown_time : float = 1

@export var speed_multiplier : float = 1

@export var filter : ObjectManager.ObjectType = ObjectManager.ObjectType.LARVAE

@export var edge_filtered_color = Color(0.929, 0.702, 0.243)
@export var edge_unfiltered_color = Color(0.702, 0.498, 0.631, 1.0)


@export var tl_filtered : bool = false
@export var tr_filtered : bool = false
@export var l_filtered : bool = false
@export var r_filtered : bool = false
@export var bl_filtered : bool = false
@export var br_filtered : bool = false

func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(Dancepad) > Setting up edges")
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
	
	dancepad_sprite = $HsDancepad
	texture = preload("res://Assets/Images/Structures/HS_Dancepad.png")
	
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
	if !get_edge_filtered(HexManager.HexDirection.TopL): edge_tl.visible = false
	if !get_edge_filtered(HexManager.HexDirection.TopR): edge_tr.visible = false
	if !get_edge_filtered(HexManager.HexDirection.MidL): edge_l.visible = false
	if !get_edge_filtered(HexManager.HexDirection.MidR): edge_r.visible = false
	if !get_edge_filtered(HexManager.HexDirection.BotL): edge_bl.visible = false
	if !get_edge_filtered(HexManager.HexDirection.BotR): edge_br.visible = false

func toggle_edge(_direction:HexManager.HexDirection) -> void:
	print_rich(DEBUG_NAME,"ToggleEdge > Setting edge '"+str(_direction)+"' to " + ("filtered" if !get_edge_filtered(_direction) else "unfiltered"))
	set_edge(_direction,!get_edge_filtered(_direction))

func set_edge(_direction:HexManager.HexDirection, _filter:bool) -> void:
	var _text = "V" if _filter else "*"
	var _color = edge_filtered_color if _filter else edge_unfiltered_color
	
	match _direction:
		HexManager.HexDirection.TopL:
			tl_filtered = _filter
			edge_tl.text = _text
			edge_tl.modulate = _color
			
		HexManager.HexDirection.TopR:
			tr_filtered = _filter
			edge_tr.text = _text
			edge_tr.modulate = _color
			
		HexManager.HexDirection.MidL:
			l_filtered = _filter
			edge_l.text = _text
			edge_l.modulate = _color
			
		HexManager.HexDirection.MidR:
			r_filtered = _filter
			edge_r.text = _text
			edge_r.modulate = _color
			
		HexManager.HexDirection.BotL:
			bl_filtered = _filter
			edge_bl.text = _text
			edge_bl.modulate = _color
			
		HexManager.HexDirection.BotR:
			br_filtered = _filter
			edge_br.text = _text
			edge_br.modulate = _color
	
	#if !is_waiting_for_output_removed_by_player:
		#offer_my_output()
	

func get_edge_filtered(_direction:HexManager.HexDirection) -> bool:
	match _direction:
		HexManager.HexDirection.TopL: return tl_filtered
		HexManager.HexDirection.TopR: return tr_filtered
		HexManager.HexDirection.MidL: return l_filtered
		HexManager.HexDirection.MidR: return r_filtered
		HexManager.HexDirection.BotL: return bl_filtered
		HexManager.HexDirection.BotR: return br_filtered
	push_error(DEBUG_NAME,"GetEdgeFiltered > [color=red] Bad direction!")
	
	return false




func nectar_dropped_here(_nectar:Nectar) -> bool:
	if !active:
		return false
	
	#_nectar.queue_free()
	ObjectManager.move_and_destroy(_nectar,hex.global_position)
	filter = ObjectManager.ObjectType.NECTAR
	
	return true

func pollen_dropped_here(_pollen:Pollen) -> bool:
	if !active:
		return false
	
	#_pollen.queue_free()	
	ObjectManager.move_and_destroy(_pollen,hex.global_position)
	filter = ObjectManager.ObjectType.POLLEN
	
	return true

func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	if !active:
		print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > No space for RoyalJelly! Returning false")
		return false
	
	#_royal_jelly.queue_free()
	ObjectManager.move_and_destroy(_royal_jelly,hex.global_position)
	filter = ObjectManager.ObjectType.ROYAL_JELLY
	
	return true


func activate() -> void:
	print_rich(DEBUG_NAME,"Activate > Worker assigned, beginning to produce!")
	dancepad_sprite.texture = texture
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
		set_edge(HexManager.HexDirection.TopL,true)
		set_edge(HexManager.HexDirection.TopR,true)
		set_edge(HexManager.HexDirection.MidL,true)
		set_edge(HexManager.HexDirection.MidR,false)
		set_edge(HexManager.HexDirection.BotL,false)
		set_edge(HexManager.HexDirection.BotR,false)

func _tr_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		set_edge(HexManager.HexDirection.TopL,true)
		set_edge(HexManager.HexDirection.TopR,true)
		set_edge(HexManager.HexDirection.MidL,false)
		set_edge(HexManager.HexDirection.MidR,true)
		set_edge(HexManager.HexDirection.BotL,false)
		set_edge(HexManager.HexDirection.BotR,false)

func _l_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		set_edge(HexManager.HexDirection.TopL,true)
		set_edge(HexManager.HexDirection.TopR,false)
		set_edge(HexManager.HexDirection.MidL,true)
		set_edge(HexManager.HexDirection.MidR,false)
		set_edge(HexManager.HexDirection.BotL,true)
		set_edge(HexManager.HexDirection.BotR,false)

func _r_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		set_edge(HexManager.HexDirection.TopL,false)
		set_edge(HexManager.HexDirection.TopR,true)
		set_edge(HexManager.HexDirection.MidL,false)
		set_edge(HexManager.HexDirection.MidR,true)
		set_edge(HexManager.HexDirection.BotL,false)
		set_edge(HexManager.HexDirection.BotR,true)

func _bl_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):		
		set_edge(HexManager.HexDirection.TopL,false)
		set_edge(HexManager.HexDirection.TopR,false)
		set_edge(HexManager.HexDirection.MidL,true)
		set_edge(HexManager.HexDirection.MidR,false)
		set_edge(HexManager.HexDirection.BotL,true)
		set_edge(HexManager.HexDirection.BotR,true)

func _br_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		set_edge(HexManager.HexDirection.TopL,false)
		set_edge(HexManager.HexDirection.TopR,false)
		set_edge(HexManager.HexDirection.MidL,false)
		set_edge(HexManager.HexDirection.MidR,true)
		set_edge(HexManager.HexDirection.BotL,true)
		set_edge(HexManager.HexDirection.BotR,true)


func _on_direction_mouse_entered() -> void:
	hex._on_mouse_entered()

func _on_direction_mouse_exited() -> void:
	hex._on_mouse_exited()
