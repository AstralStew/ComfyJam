class_name HexStructure extends Node2D
var DEBUG_NAME : String :
	get: return _debug_name()
func _debug_name() -> String: return "[b][" + get_parent().name + "/HexStructure][/b] "

@export var max_workers : int = 0
@export var assigned_workers : int = 0

@export var output_amount : int = 1
@export var output_candidates : Array[ObjectManager.ObjectType] = []


@export_category("READ ONLY")

@export var active : bool = false
@export var output : Node2D = null
@export var _outputs : Array[ObjectManager.ObjectType] = []

signal on_outputs_empty

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup()


func _setup() -> void:
	print_rich(DEBUG_NAME,"Setup > Default (does nothing)")


func add_object_to_output() -> void:
	if output_candidates.is_empty():
		print_rich("AddObjectToOutput > No output candidates assigned, cancelling")
		return
	
	for i in output_amount:
		_outputs.append(output_candidates.pick_random())


func output_object() -> bool:
	if _outputs.is_empty():
		print_rich("AddObjectToOutput > No outputs, cancelling")
		return false
	
	# Create an object from the last chosen returnable type
	output = ObjectManager.create_object(_outputs.pop_back())
	output.global_position = self.global_position
	
	print_rich(DEBUG_NAME,"OutputObject > Popped out '"+output.name+"'! Waiting for player to grab...")
	
	output.on_move.connect(output_removed.bind(output))
	
	return true


func output_removed(_object:Node2D):
	_object.on_move.disconnect(output_removed.bind(_object))
	
	if !output_object():
		print_rich("OutputRemoved > No outputs left!")
		on_outputs_empty.emit()



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
	return true


func nectar_dropped_here(_nectar:Nectar) -> bool:
	return false

func pollen_dropped_here(_pollen:Pollen) -> bool:
	return false

func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	return false
