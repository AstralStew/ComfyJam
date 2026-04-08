class_name HexStructure extends Node2D
var DEBUG_NAME : String :
	get: return _debug_name()
func _debug_name() -> String: return "[b][" + get_parent().name + "/HexStructure][/b]"

@export var max_workers : int = 0
@export var assigned_workers : int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


func _setup() -> void:
	print_rich(DEBUG_NAME,"Setup > Default (does nothing)")


func assign_worker(_worker:WorkerBee) -> bool:
	if assigned_workers >= max_workers:
		print_rich(DEBUG_NAME,"AssignWorker > Already at max workers, ignoring")
		return false
	
	_worker.queue_free()
	assigned_workers += 1
	return true
	
