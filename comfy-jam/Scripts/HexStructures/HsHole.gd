class_name HexStructureHole extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsHole][/b]"

var _returnables : Array[Node2D] = []


func _setup() -> void:
	print_rich(DEBUG_NAME,"Setup > ")
	max_workers = 1
