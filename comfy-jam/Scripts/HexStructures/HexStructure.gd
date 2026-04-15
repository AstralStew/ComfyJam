class_name HexStructure extends Node2D
var DEBUG_NAME : String :
	get: return _debug_name()
func _debug_name() -> String: return "[b][" + get_parent().name + "/HexStructure][/b] "

var hex : Hex = null

@export var max_workers : int = 0
@export var assigned_workers : int = 0

@export var output_amount : int = 1
@export var output_cooldown : float = 0.1
@export var output_scale : float = 0.64
@export var output_candidates : Array[ObjectManager.ObjectType] = []

@export var output_notify_delay : float = 2

@export_category("READ ONLY")

@export var active : bool = false
@export var output : Node2D = null
@export var _outputs : Array[ObjectManager.ObjectType] = []
@export var output_on_cooldown : bool = false

@export var at_max_workers : bool = false :
	get: return assigned_workers >= max_workers


var is_waiting_to_offer_my_output : bool = false
var is_waiting_for_output_removed : bool = false
var is_waiting_for_output_removed_by_player : bool = false
var is_outputting_object : bool = false

signal on_activate
#signal on_outsput_object
signal on_output_able_to_be_taken
signal on_output_object_removed
signal on_outputs_added
signal on_outputs_empty

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#_setup()
	



func _setup() -> void:
	print_rich(DEBUG_NAME,"Setup > Calculating adjacent hexes")
	
	on_output_able_to_be_taken.connect(offer_my_output)
	on_activate.connect(ask_others_to_offer_their_output)
	on_output_object_removed.connect(ask_others_to_offer_their_output)
	
	on_outputs_added.connect(update_tooltip_info)
	on_output_object_removed.connect(update_tooltip_info)
		#func():
			#if HexManager.last_hovered_hex == hex:
				#Tooltip.set_tooltip_type(Tooltip.TooltipType.HEX,hex)
	#)
	
	
	# Add signals from each adjacent hex structure 
	var _adacent_hexes = HexManager.get_adjacent_hexes(hex)
	_adacent_hexes.shuffle()
	for _adjacent_hex:Hex in _adacent_hexes:
		if _adjacent_hex.structure != null:
			print_rich(DEBUG_NAME,"Setup > Checking adjacent hex '"+_adjacent_hex.name+"''s structure '"+_adjacent_hex.structure.name+"'")
			_adjacent_hex.structure.adjacent_hex_updated(hex)
	
	#ask_others_to_offer_their_output()

func update_tooltip_info() -> void:
	if HexManager.last_hovered_hex == hex:
		Tooltip.set_tooltip_type(Tooltip.TooltipType.HEX,hex)

func offer_my_output() -> void:
	if is_waiting_to_offer_my_output:
		print_rich(DEBUG_NAME,"[color=pink]OfferMyOutput(super) > Already waiting to update adjacent hexes, cancelling.")
		return
	if !is_waiting_for_output_removed:
		print_rich(DEBUG_NAME,"[color=pink]OfferMyOutput(super) > We aren't even waiting for output to be removed, cancelling.")
		return
	if is_waiting_for_output_removed_by_player:
		print_rich(DEBUG_NAME,"[color=pink]OfferMyOutput(Honeycomb) > Still waiting for output to be removed by player, cancelling")
		return
	
	is_waiting_to_offer_my_output = true
	
	#await get_tree().create_timer(outpu/t_notify_delay).timeout
	#
	#if !is_waiting_for_output_removed:
		#print_rich(DEBUG_NAME,"[color=pink]OfferMyOutput(super) > Not longer waiting for output to be removed, waiting a frame then flagging that I'm no longer waiting to update adjacent hexes.")
		#await get_tree().process_frame
		#print_rich(DEBUG_NAME,"[color=pink]OfferMyOutput(super) > Finished waiting a frame, flagging that I'm no longer waiting to update adjacent hexes.")
		#is_waiting_to_offer_my_output = false
		#return
	
	var _adjacent_hexes = HexManager.get_adjacent_hexes(hex)
	_adjacent_hexes.shuffle()
	var _took_object_from_me : bool = false
	for _adjacent_hex:Hex in _adjacent_hexes:
		if _adjacent_hex.structure != null:
			#if _adjacent_hex.structure is not HexStructureHoneycomb: adjacent_hex_updated(_adjacent_hex)
			if !_took_object_from_me:
				print_rich(DEBUG_NAME,"OfferMyOutput(super)  > Adjacent hex '"+_adjacent_hex.name+"' has a structure, asking if it wants the object")
				if _adjacent_hex.structure.adjacent_hex_updated(hex):
					print_rich(DEBUG_NAME,"OfferMyOutput(super)  > Adjacent hex '"+_adjacent_hex.name+"' accepted!")
					_took_object_from_me = true
				else: print_rich(DEBUG_NAME,"OfferMyOutput(super)  > Adjacent hex '"+_adjacent_hex.name+"' said no.")
	
	is_waiting_to_offer_my_output = false

func ask_others_to_offer_their_output() -> void:
	var _adacent_hexes = HexManager.get_adjacent_hexes(hex)
	_adacent_hexes.shuffle()
	for _adjacent_hex:Hex in _adacent_hexes:
		if _adjacent_hex.structure != null:
			_adjacent_hex.structure.offer_my_output()

func adjacent_hex_updated(_adjacent_hex:Hex) -> bool:
	print_rich(DEBUG_NAME,"AdjacentHexUpdated > Checking adjacent hex '"+_adjacent_hex.name+"'...")
	
	if _adjacent_hex.structure == null:
		print_rich(DEBUG_NAME,"AdjacentHexUpdated > Adjacent hex '"+_adjacent_hex.name+"' has no structure, returning")
		return false
	
	
	if !_adjacent_hex.structure.active:
		print_rich(DEBUG_NAME,"AdjacentHexUpdated > Adjacent hex '"+_adjacent_hex.name+"''s structure '"+_adjacent_hex.structure.name+"' is not active, returning")
		return false
	
	print_rich(DEBUG_NAME,"AdjacentHexUpdated > Hex structure '"+_adjacent_hex.structure.name+"' valid, checking its output")
	
	if _adjacent_hex.structure.output != null:
		if object_dropped_here(_adjacent_hex.structure.output):
			_adjacent_hex.structure.output_removed(null)
			return true
	
	return false
	


func add_object_to_output(_optional_object : int = -1) -> void:
	if _optional_object != -1:
		_outputs.append(_optional_object as ObjectManager.ObjectType)
		on_outputs_added.emit()
		return
	
	else:
		if output_candidates.is_empty():
			print_rich("AddObjectToOutput > No output candidates assigned, cancelling")
			return
		
		for i in output_amount:
			_outputs.append(output_candidates.pick_random())
	
	on_outputs_added.emit()


func output_object() -> bool:
	if is_waiting_for_output_removed:
		return false
	
	if _outputs.is_empty():
		print_rich("OutputObject > No outputs, cancelling")
		return false
	
	if output != null:
		print_rich("OutputObject > Already have an output ('"+output.name+"'), cancelling")
		return false
	
	# Create an object from the last chosen returnable type
	var _output = ObjectManager.create_object(_outputs.pop_front(),global_position - Vector2(0,6))
	_output.global_scale *= output_scale
	_output.show_outline() # .material = preload("res://Assets/Materials/selection_material.tres")
	_output.spawning_animation(output_notify_delay)
	output = _output
	
	print_rich(DEBUG_NAME,"OutputObject > Popped out '"+output.name+"'! Giving chance for player to grab...")
	
	
	#output.on_dragged.connect(output_removed.bind(output))
	waiting_for_output_removed()
	
	return true


func on_signal_choice(_signals:Array[Signal]) -> Signal:
	
	var refcounted = RefCounted.new()
	refcounted.add_user_signal("result")
		
	for _signal in _signals:
		_signal.connect(
			func(...params):
				refcounted.emit_signal("result",_signal,params),
				CONNECT_ONE_SHOT
		)
	
	return Signal(refcounted, "result")

func waiting_for_output_removed() -> void:
	print_rich(DEBUG_NAME,"[color=orange] We are now waiting for output to be removed")
	is_waiting_for_output_removed = true
	is_waiting_for_output_removed_by_player = true
	# Wait for player drag or wait a little while before telling other hexes
	var _first_signal = get_tree().create_timer(output_notify_delay).timeout
	var _second_signal = output.on_dragged
	var _result = await on_signal_choice([_first_signal,_second_signal])
	if _result[0] == _first_signal:
		print_rich(DEBUG_NAME,"[color=orange] WaitingForOutputRemoved > Player hasn't grabbed output yet, telling hexes around me")
		is_waiting_for_output_removed_by_player = false
		on_output_able_to_be_taken.emit()
	else:
		print_rich(DEBUG_NAME,"[color=orange] WaitingForOutputRemoved > Player grabbed output, cancelling here")
		is_waiting_for_output_removed_by_player = false
		output_removed(output)
		return
	
	if is_waiting_for_output_removed_by_player:
		push_error(DEBUG_NAME,"[color=red]WaitingForOutputRemoved SHOULD NOT BE POSSIBLE")
	
	if !ObjectManager.check_if_object_is_ours(output):
		print_rich(DEBUG_NAME,"[color=green] WaitingForOutputRemoved > Is this a problem?")
		is_waiting_for_output_removed = false
		return
	
	_first_signal = output.on_dragged
	_second_signal = on_output_object_removed
	_result = await on_signal_choice([_first_signal,_second_signal])
	if _result[0] == _first_signal:
		print_rich(DEBUG_NAME,"WaitingForOutputRemoved > Player finally grabbed output!")
		output_removed(output)
		#is_waiting_for_output_removed = false
		return
	else:
		print_rich(DEBUG_NAME,"WaitingForOutputRemoved > Something else grabbed output, finished.")
		is_waiting_for_output_removed = false
		return


func output_removed(_object:Node2D):
	output_on_cooldown = true
	await get_tree().process_frame
	while get_tree().paused:
		await get_tree().process_frame
	#if _object != null: _object.on_dragged.disconnect(output_removed.bind(_object))
	is_waiting_for_output_removed = false
	is_waiting_for_output_removed_by_player = false
	output = null
	
	on_output_object_removed.emit()
	
	if _outputs.is_empty():
		print_rich("OutputRemoved > No outputs left!")
		on_outputs_empty.emit()
		output_on_cooldown = false
		return
	
	await get_tree().create_timer(output_cooldown).timeout
	output_on_cooldown = false
	
	output_object()
	



func object_dropped_here(_object:Node2D) -> bool:
	print_rich(DEBUG_NAME,"ObjectDroppedHere > Object = '",_object.name,"'")
	if (_object as Larvae) != null:
		print_rich(DEBUG_NAME,"ObjectDroppedHere > It's a Larvae...")
		return larvae_dropped_here(_object as Larvae)
	elif (_object as WorkerBee) != null:
		print_rich(DEBUG_NAME,"ObjectDroppedHere > It's a WorkerBee...")
		return worker_dropped_here(_object as WorkerBee)
	elif (_object as Nectar) != null:
		print_rich(DEBUG_NAME,"ObjectDroppedHere > It's a Nectar...")
		return nectar_dropped_here(_object as Nectar)
	elif (_object as Pollen) != null:
		print_rich(DEBUG_NAME,"ObjectDroppedHere > It's a Pollen...")
		return pollen_dropped_here(_object as Pollen)
	elif (_object as RoyalJelly) != null:
		print_rich(DEBUG_NAME,"ObjectDroppedHere > It's a Royal Jelly...")
		return royal_jelly_dropped_here(_object as RoyalJelly)
	return false


func worker_dropped_here(_worker:WorkerBee) -> bool:
	if assigned_workers >= max_workers:
		print_rich(DEBUG_NAME,"AssignWorker > Already at max workers, ignoring")
		return false
	
	print_rich(DEBUG_NAME,"WorkerDroppedHere > Assigning worker...")
	_worker.queue_free()
	assigned_workers += 1
	
	# Activate structure
	if !active && assigned_workers == 1:
		activate()
	
	return true


func activate() -> void:
	print_rich(DEBUG_NAME,"Activate(super) > Finished activating!")
	on_activate.emit()

func nectar_dropped_here(_nectar:Nectar) -> bool:
	print_rich(DEBUG_NAME,"NectarDroppedHere(super) > (oops, I don't do anything with this...)")
	return false

func pollen_dropped_here(_pollen:Pollen) -> bool:
	print_rich(DEBUG_NAME,"PollenDroppedHere(super) > (oops, I don't do anything with this...)")
	return false

func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	print_rich(DEBUG_NAME,"RoyalJellyDroppedHere(super) > (oops, I don't do anything with this...)")
	return false

func larvae_dropped_here(_larvae:Larvae) -> bool:
	print_rich(DEBUG_NAME,"LarvaeDroppedHere(super) > (oops, I don't do anything with this...)")
	return false
