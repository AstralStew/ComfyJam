class_name HexStructureDancepad extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsDancepad][/b] "

var edge_tl : Label = null
var edge_tr : Label = null
var edge_l : Label = null
var edge_r : Label = null
var edge_bl : Label = null
var edge_br : Label = null

var _sprite : AnimatedSprite2D = null
var progress_hex : TextureProgressBar  = null

@export var startup_time : float = 1
@export var wrapup_time : float = 1

@export_category("READ ONLY")

@export var cooling_down : bool = false
@export var cooldown_time : float = 1

@export var speed_multiplier : float = 1

@export var filter_active : bool = false
@export var filter : ObjectManager.ObjectType = ObjectManager.ObjectType.LARVAE

@export var edge_filtered_color = Color(0.578, 0.784, 0.679, 1.0)
@export var edge_unfiltered_color = Color(0.804, 0.478, 0.529, 1.0)


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
	hide_edges()
	
	progress_hex = $ProgressHex
	_sprite = $HsDancepad
	_sprite.play("thinking")
	
	cooldown_time = HiveManager.upgrade_dancepad_cooldown
	speed_multiplier = HiveManager.upgrade_global_speed_multiplier
	
	max_workers = 1
	
	#on_output_object_removed.connect(check_adjacent_hexes)
	#on_outputs_added.connect(cooldown)
	
	hex.on_hex_hovered.connect(show_edges)
	hex.on_hex_unhovered.connect(hide_edges)
	

func adjacent_hex_updated(_adjacent_hex:Hex) -> bool:
	if cooling_down:
		print_rich(DEBUG_NAME,"AdjacentHexUpdated(Dancepad) > Ignoring adjacent hex '"+_adjacent_hex.name+"' due to me being a Dancepad and working on my routine!!")
		return false
	
	if !filter_active: 
		print_rich(DEBUG_NAME,"AdjacentHexUpdated(Dancepad) > Ignoring adjacent hex '"+_adjacent_hex.name+"' due to me being a Dancepad without a filter")
		return false
	
	print_rich(DEBUG_NAME,"AdjacentHexUpdated(Dancepad) > Checking adjacent hex '"+_adjacent_hex.name+"'...")
	
	if _adjacent_hex.structure == null:
		print_rich(DEBUG_NAME,"AdjacentHexUpdated(Dancepad) > Adjacent hex '"+_adjacent_hex.name+"' has no structure, returning")
		return false
	
	
	if !_adjacent_hex.structure.active:
		print_rich(DEBUG_NAME,"AdjacentHexUpdated(Dancepad) > Adjacent hex '"+_adjacent_hex.name+"''s structure '"+_adjacent_hex.structure.name+"' is not active, returning")
		return false
	
	if !check_adjacent_hex_is_filtered(_adjacent_hex):
		print_rich(DEBUG_NAME,"AdjacentHexUpdated(Dancepad) > Ignoring because we aren't filtering in the direction of '"+_adjacent_hex.name+"'!")
		return false
	
	print_rich(DEBUG_NAME,"AdjacentHexUpdated(Dancepad) > Hex structure '"+_adjacent_hex.structure.name+"' valid, checking its output")
	
	if _adjacent_hex.structure.output != null:
		if ObjectManager.get_type_of_object(_adjacent_hex.structure.output) == filter:
			ObjectManager.move_and_destroy(_adjacent_hex.structure.output,hex.global_position)
			pop_out_object(filter)
			_adjacent_hex.structure.output_removed(null)
			return true
	
	return false

func check_adjacent_hex_is_filtered(_adjacent_hex:Hex) -> bool:
	
	if HexManager.instance.get_adjacent_coord(hex.coords,HexManager.HexDirection.TopL) == _adjacent_hex.coords:
		if get_edge_filtered(HexManager.HexDirection.TopL): return true
	if HexManager.instance.get_adjacent_coord(hex.coords,HexManager.HexDirection.TopR) == _adjacent_hex.coords:
		if get_edge_filtered(HexManager.HexDirection.TopR): return true
	if HexManager.instance.get_adjacent_coord(hex.coords,HexManager.HexDirection.MidL) == _adjacent_hex.coords:
		if get_edge_filtered(HexManager.HexDirection.MidL): return true
	if HexManager.instance.get_adjacent_coord(hex.coords,HexManager.HexDirection.MidR) == _adjacent_hex.coords:
		if get_edge_filtered(HexManager.HexDirection.MidR): return true
	if HexManager.instance.get_adjacent_coord(hex.coords,HexManager.HexDirection.BotL) == _adjacent_hex.coords:
		if get_edge_filtered(HexManager.HexDirection.BotL): return true
	if HexManager.instance.get_adjacent_coord(hex.coords,HexManager.HexDirection.BotR) == _adjacent_hex.coords:
		if get_edge_filtered(HexManager.HexDirection.BotR): return true
	
	return false
	

func pop_out_object(_object:ObjectManager.ObjectType) -> void:
	var _output = ObjectManager.create_object(filter,global_position,true)
	#_output.global_scale *= output_scale
	#_output.show_outline() # .material = preload("res://Assets/Materials/selection_material.tres")
	#_output.spawning_animation(output_notify_delay)
	await get_tree().process_frame
	ObjectManager.free_stand_object(_output)
	_output.free_standing = true
	if _output is Larvae:
		_output.add_to_group("Larvae")
	elif _output is Nectar:
		_output.add_to_group("Nectar")
	elif _output is Pollen:
		_output.add_to_group("Pollen")
	elif _output is RoyalJelly:
		_output.add_to_group("RoyalJelly")
	elif _output is Honey:
		_output.add_to_group("Honey")
	
	print_rich(DEBUG_NAME,"AdjacentHexUpdated(Dancepad) > Popped out filtered object '"+_output.name+"'!")
			

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
	if !active || cooling_down:
		return false
	
	ObjectManager.move_and_destroy(_nectar,hex.global_position)
	filter = ObjectManager.ObjectType.NECTAR
	$Nectar.visible = true
	$Pollen.visible = false
	$RoyalJelly.visible = false
	$Larvae.visible = false
	$Honey.visible = false
	filter_active = true
	cooldown()
	
	return true

func pollen_dropped_here(_pollen:Pollen) -> bool:
	if !active || cooling_down:
		return false
	
	ObjectManager.move_and_destroy(_pollen,hex.global_position)
	filter = ObjectManager.ObjectType.POLLEN
	$Nectar.visible = false
	$Pollen.visible = true
	$RoyalJelly.visible = false
	$Larvae.visible = false
	$Honey.visible = false
	filter_active = true
	cooldown()
	
	return true

func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	if !active || cooling_down:
		return false
	
	ObjectManager.move_and_destroy(_royal_jelly,hex.global_position)
	filter = ObjectManager.ObjectType.ROYAL_JELLY
	$Nectar.visible = false
	$Pollen.visible = false
	$RoyalJelly.visible = true
	$Larvae.visible = false
	$Honey.visible = false
	filter_active = true
	cooldown()
	
	return true

func honey_dropped_here(_honey:Honey) -> bool:
	if !active || cooling_down:
		return false
	
	ObjectManager.move_and_destroy(_honey,hex.global_position)
	filter = ObjectManager.ObjectType.HONEY
	$Nectar.visible = false
	$Pollen.visible = false
	$RoyalJelly.visible = false
	$Larvae.visible = true
	$Honey.visible = false
	filter_active = true
	cooldown()
	
	return true

func larvae_dropped_here(_larvae:Larvae) -> bool:
	if !active || cooling_down:
		return false
	
	ObjectManager.move_and_destroy(_larvae,hex.global_position)
	filter = ObjectManager.ObjectType.ROYAL_JELLY
	$Nectar.visible = false
	$Pollen.visible = false
	$RoyalJelly.visible = false
	$Larvae.visible = false
	$Honey.visible = true
	filter_active = true
	cooldown()
	
	return true


func activate() -> void:
	print_rich(DEBUG_NAME,"Activate > Worker assigned, beginning to produce!")
	#dancepad_sprite.texture = texture_2
	active = true
	
	super()
	
	#dispensing()


var _tween : Tween = null
func cooldown() -> void:
	
	set_edge(HexManager.HexDirection.TopL,false)
	set_edge(HexManager.HexDirection.TopR,false)
	set_edge(HexManager.HexDirection.MidL,false)
	set_edge(HexManager.HexDirection.MidR,false)
	set_edge(HexManager.HexDirection.BotL,false)
	set_edge(HexManager.HexDirection.BotR,false)
	
	print_rich(DEBUG_NAME,"Cooldown > Time to come up with new dance routine...")
	
	cooling_down = true
	
	await start_cooling_down()
	
	progress_hex.value = 0
	progress_hex.visible = true
	
	if _tween: _tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(progress_hex,"value",progress_hex.max_value,cooldown_time / speed_multiplier)
	
	await get_tree().create_timer(cooldown_time / speed_multiplier).timeout
	
	await finish_cooling_down()
	
	progress_hex.visible = false
	progress_hex.value = 0
	
	cooling_down = false
	
	
	print_rich(DEBUG_NAME,"Cooldown > New routine figured out! TIME TO DANCE!")
	
	ask_others_to_offer_their_output()
	



func start_cooling_down() -> void:
	#sprite.texture = texture_2
	_sprite.play("thinking")
	#$HsDancepad.modulate = Color(1,1,1,0.7)
	await get_tree().create_timer(startup_time).timeout
	

func finish_cooling_down() -> void:
	#sprite.texture = texture_1
	_sprite.play("dancing")
	#$HsDancepad.modulate = Color(1,1,1,1)
	await get_tree().create_timer(wrapup_time).timeout



func _tl_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		set_edge(HexManager.HexDirection.TopL,true)
		set_edge(HexManager.HexDirection.TopR,true)
		set_edge(HexManager.HexDirection.MidL,true)
		set_edge(HexManager.HexDirection.MidR,false)
		set_edge(HexManager.HexDirection.BotL,false)
		set_edge(HexManager.HexDirection.BotR,false)
		ask_others_to_offer_their_output()

func _tr_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		set_edge(HexManager.HexDirection.TopL,true)
		set_edge(HexManager.HexDirection.TopR,true)
		set_edge(HexManager.HexDirection.MidL,false)
		set_edge(HexManager.HexDirection.MidR,true)
		set_edge(HexManager.HexDirection.BotL,false)
		set_edge(HexManager.HexDirection.BotR,false)
		ask_others_to_offer_their_output()

func _l_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		set_edge(HexManager.HexDirection.TopL,true)
		set_edge(HexManager.HexDirection.TopR,false)
		set_edge(HexManager.HexDirection.MidL,true)
		set_edge(HexManager.HexDirection.MidR,false)
		set_edge(HexManager.HexDirection.BotL,true)
		set_edge(HexManager.HexDirection.BotR,false)
		ask_others_to_offer_their_output()

func _r_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		set_edge(HexManager.HexDirection.TopL,false)
		set_edge(HexManager.HexDirection.TopR,true)
		set_edge(HexManager.HexDirection.MidL,false)
		set_edge(HexManager.HexDirection.MidR,true)
		set_edge(HexManager.HexDirection.BotL,false)
		set_edge(HexManager.HexDirection.BotR,true)
		ask_others_to_offer_their_output()

func _bl_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):		
		set_edge(HexManager.HexDirection.TopL,false)
		set_edge(HexManager.HexDirection.TopR,false)
		set_edge(HexManager.HexDirection.MidL,true)
		set_edge(HexManager.HexDirection.MidR,false)
		set_edge(HexManager.HexDirection.BotL,true)
		set_edge(HexManager.HexDirection.BotR,true)
		ask_others_to_offer_their_output()

func _br_gui_event(event:InputEvent) -> void:	
	if event is InputEventMouse && event.is_action_pressed("LeftClick"):
		set_edge(HexManager.HexDirection.TopL,false)
		set_edge(HexManager.HexDirection.TopR,false)
		set_edge(HexManager.HexDirection.MidL,false)
		set_edge(HexManager.HexDirection.MidR,true)
		set_edge(HexManager.HexDirection.BotL,true)
		set_edge(HexManager.HexDirection.BotR,true)
		ask_others_to_offer_their_output()


func _on_direction_mouse_entered() -> void:
	hex._on_mouse_entered()

func _on_direction_mouse_exited() -> void:
	hex._on_mouse_exited()
