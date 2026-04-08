class_name StructureManager extends Node
const DEBUG_NAME : String = "[b][StructureManager][/b] "

enum StructureType {BLANK,HOLE}

static var instance : StructureManager = null

static var hole_prefab = preload("res://Scenes/hs_hole.tscn")


func _enter_tree() -> void:
	instance = self



static func set_structure(_hex:Hex,_type:StructureType) -> bool:
	
	if _hex.structure != null:
		print(DEBUG_NAME,"SetStructure > Hex '",_hex.name,"' already has a structure! Returning false")
		return false
	
	var _new_structure : HexStructure = null
	match _type:
		StructureType.BLANK:
			print_rich(DEBUG_NAME,"SetStructure > Type = BLANK, removing current structure [color=red](not implemented yet)")
		StructureType.HOLE:
			print_rich(DEBUG_NAME,"SetStructure > Type = HOLE, creating structure")
			_new_structure = hole_prefab.instantiate()
			_hex.add_child(_new_structure)
	
	return true
