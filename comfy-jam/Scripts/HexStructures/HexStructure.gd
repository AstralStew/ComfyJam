class_name HexStructure extends Node2D
var DEBUG_NAME : String :
	get: return _debug_name()
func _debug_name() -> String: return "[b][" + get_parent().name + "/HexStructure][/b] "

@export var max_workers : int = 0
@export var assigned_workers : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup()


func _setup() -> void:
	print_rich(DEBUG_NAME,"Setup > Default (does nothing)")


func assign_worker(_worker:WorkerBee) -> bool:
	if assigned_workers >= max_workers:
		print_rich(DEBUG_NAME,"AssignWorker > Already at max workers, ignoring")
		return false
	
	_worker.queue_free()
	assigned_workers += 1
	print_rich(DEBUG_NAME,"[color=999900] assigned workers = "+str(assigned_workers))
	return true

func object_dropped_here(_object:Node2D) -> void:
	print_rich(DEBUG_NAME,"ObjectDroppedHere > Object = '",_object.name,"'")
	if (_object as WorkerBee) != null:
		print_rich(DEBUG_NAME,"ObjectDroppedHere > Object is WorkerBee! Assigning here...")
		assign_worker(_object as WorkerBee)

#func clicked() -> void:
	#pass

#func unclicked() -> void:
	#if (SelectionManager.current_selection as WorkerBee) != null:
		#SelectionManager.current_selection.queue_free()
		#assigned_workers += 1
