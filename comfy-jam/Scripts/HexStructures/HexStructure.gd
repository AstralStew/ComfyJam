class_name HexStructure extends Node2D
var DEBUG_NAME : String :
	get: return _debug_name()
func _debug_name() -> String: return "[b][" + get_parent().name + "/HexStructure][/b] "

var hex : Hex = null

@export var max_workers : int = 0
@export var assigned_workers : int = 0

@export var output_amount : int = 1
@export var output_cooldown : float = 0.1
@export var output_candidates : Array[ObjectManager.ObjectType] = []

@export var adjacent_output_removal_delay : float = 0.5

@export_category("READ ONLY")

@export var active : bool = false
@export var output : Node2D = null
@export var _outputs : Array[ObjectManager.ObjectType] = []
@export var output_on_cooldown : bool = false

@export var at_max_workers : bool = false :
	get: return assigned_workers >= max_workers


signal on_activate
signal on_output_object
signal on_output_object_removed
signal on_outputs_added
signal on_outputs_empty

## Called when the node enters the scene tree for the first time.
#func _ready() -> void:
	#_setup()
	



func _setup() -> void:
	print_rich(DEBUG_NAME,"Setup > Calculating adjacent hexes")
	
	on_output_object.connect(update_adjacent_hexes)
	on_activate.connect(update_adjacent_hexes)
	
	on_outputs_added.connect(
		func():
			if HexManager.last_hovered_hex == hex:
				Tooltip.set_tooltip_type(Tooltip.TooltipType.HEX,hex)
	)
	on_output_object_removed.connect(
		func():
			if HexManager.last_hovered_hex == hex:
				Tooltip.set_tooltip_type(Tooltip.TooltipType.HEX,hex)
	)
	
	
	# Add signals from each adjacent hex structure 
	var _adacent_hexes = HexManager.get_adjacent_hexes(hex)
	_adacent_hexes.shuffle()
	for _adjacent_hex:Hex in _adacent_hexes:
		if _adjacent_hex.structure != null:
			print_rich(DEBUG_NAME,"Setup > Checking adjacent hex '"+_adjacent_hex.name+"''s structure '"+_adjacent_hex.structure.name+"'")
			#_adjacent_hex.structure.on_output_object.connect(adjacent_hex_updated.bind(_adjacent_hex))
			#_adjacent_hex.structure.on_output_object_removed.connect(adjacent_hex_updated.bind(_adjacent_hex))
			_adjacent_hex.structure.adjacent_hex_updated(hex)

func update_adjacent_hexes() -> void:
	await get_tree().create_timer(adjacent_output_removal_delay).timeout
	
	var _adacent_hexes = HexManager.get_adjacent_hexes(hex)
	_adacent_hexes.shuffle()
	var _took_object_from_me : bool = false
	for _adjacent_hex:Hex in _adacent_hexes:
		if _adjacent_hex.structure != null:
			#adjacent_hex_updated(_adjacent_hex)
			if !_took_object_from_me:
				print_rich(DEBUG_NAME,"UpdateAdjacentHexes > Adjacent hex '"+_adjacent_hex.name+"' has a structure, asking if it wants the object")
				if _adjacent_hex.structure.adjacent_hex_updated(hex):
					print_rich(DEBUG_NAME,"UpdateAdjacentHexes > Adjacent hex '"+_adjacent_hex.name+"' accepted!")
					_took_object_from_me = true
			print_rich(DEBUG_NAME,"UpdateAdjacentHexes > Adjacent hex '"+_adjacent_hex.name+"' said no.")


func adjacent_hex_updated(_hex:Hex) -> bool:
	print_rich(DEBUG_NAME,"AdjacentHexUpdated > Checking adjacent hex '"+_hex.name+"'...")
	
	if _hex.structure == null:
		print_rich(DEBUG_NAME,"AdjacentHexUpdated > Adjacent hex '"+_hex.name+"' has no structure, returning")
		return false
	
	
	if !_hex.structure.active:
		print_rich(DEBUG_NAME,"AdjacentHexUpdated > Adjacent hex '"+_hex.name+"''s structure '"+_hex.structure.name+"' is not active, returning")
		return false
	
	print_rich(DEBUG_NAME,"AdjacentHexUpdated > Hex structure '"+_hex.structure.name+"' valid, checking its output")
	
	if _hex.structure.output != null:
		if object_dropped_here(_hex.structure.output):
			_hex.structure.output_removed(null)
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
	if _outputs.is_empty():
		print_rich("AddObjectToOutput > No outputs, cancelling")
		return false
	
	if output != null:
		print_rich("AddObjectToOutput > Already have an output ('"+output.name+"'), cancelling")
		return false
	
	# Create an object from the last chosen returnable type
	output = ObjectManager.create_object(_outputs.pop_front(),global_position)
	output.global_scale *= 0.8
	
	on_output_object.emit()
	
	print_rich(DEBUG_NAME,"OutputObject > Popped out '"+output.name+"'! Waiting for player to grab...")
	
	output.on_dragged.connect(output_removed.bind(output))
	
	return true



func output_removed(_object:Node2D):
	if _object != null: _object.on_dragged.disconnect(output_removed.bind(_object))
	output = null
	
	on_output_object_removed.emit()
	
	if _outputs.is_empty():
		print_rich("OutputRemoved > No outputs left!")
		on_outputs_empty.emit()
		return
	
	output_on_cooldown = true
	await get_tree().create_timer(output_cooldown).timeout
	output_on_cooldown = false
	
	output_object()
	



func object_dropped_here(_object:Node2D) -> bool:
	print_rich(DEBUG_NAME,"ObjectDroppedHere > Object = '",_object.name,"'")
	if (_object as WorkerBee) != null:
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
	return false

func pollen_dropped_here(_pollen:Pollen) -> bool:
	return false

func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	return false
