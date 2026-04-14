class_name HexStructureImpassable extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsImpassable][/b] "


@export var speed_multiplier : float = 1


func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(Impassable) > Yep!")
	
	max_workers = 0


func adjacent_hex_updated(_hex:Hex) -> bool:
	return false
