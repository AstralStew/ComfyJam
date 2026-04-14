class_name StructureManager extends Node
const DEBUG_NAME : String = "[b][StructureManager][/b] "

enum StructureType {BLANK,HOLE,JELLY_FACTORY,NURSERY,CONSTRUCTION,HONEYCOMB,IMPASSABLE,KISS_STATION}

static var instance : StructureManager = null

static var hole_prefab = preload("res://Scenes/hs_hole.tscn")
static var jelly_factory_prefab = preload("res://Scenes/hs_jelly_factory.tscn")
static var nursery_prefab = preload("res://Scenes/hs_nursery.tscn")
static var construction_prefab = preload("res://Scenes/hs_construction.tscn")
static var honeycomb_prefab = preload("res://Scenes/hs_honeycomb.tscn")
static var impassable_prefab = preload("res://Scenes/hs_impassable.tscn")
static var kiss_station_prefab = preload("res://Scenes/hs_kiss_station.tscn")

static var build_menu : BuildMenu = null

func _ready() -> void:
	instance = self
	
	build_menu = $"../SubViewportContainer/SubViewport/BuildMenu"


static func set_structure(_hex:Hex,_type:StructureType,_construction_type:StructureType=StructureType.BLANK) -> bool:
	
	if _hex.structure != null:
		print(DEBUG_NAME,"SetStructure > Hex '",_hex.name,"' already has a structure! Returning false")
		return false
	
	var _new_structure : HexStructure = null
	match _type:
		StructureType.BLANK:
			print_rich(DEBUG_NAME,"SetStructure > Type = BLANK, removing current structure [color=red](not implemented yet)")
		StructureType.HOLE:
			print_rich(DEBUG_NAME,"SetStructure > Type = HOLE, creating a Hole structure")
			_new_structure = hole_prefab.instantiate()
			_hex.add_child(_new_structure)
			_hex.structure = _new_structure
			_hex.structure._setup()
		StructureType.JELLY_FACTORY:
			print_rich(DEBUG_NAME,"SetStructure > Type = JELLY_FACTORY, creating a Jelly Factory structure")
			_new_structure = jelly_factory_prefab.instantiate()
			_hex.add_child(_new_structure)
			_hex.structure = _new_structure
			_hex.structure._setup()
		StructureType.NURSERY:
			print_rich(DEBUG_NAME,"SetStructure > Type = NURSERY, creating a Nursery structure")
			_new_structure = nursery_prefab.instantiate()
			_hex.add_child(_new_structure)
			_hex.structure = _new_structure
			_hex.structure._setup()
		StructureType.CONSTRUCTION:
			print_rich(DEBUG_NAME,"SetStructure > Type = CONSTRUCTION, creating a Construction structure with construction type '"+str(_construction_type)+"'")
			_new_structure = construction_prefab.instantiate()
			_hex.add_child(_new_structure)
			_hex.structure = _new_structure
			_hex.structure._setup()
			(_hex.structure as HexStructureConstruction).set_construction_type(_construction_type)
		StructureType.HONEYCOMB:
			print_rich(DEBUG_NAME,"SetStructure > Type = HONEYCOMB, creating a Honeycomb structure ")
			_new_structure = honeycomb_prefab.instantiate()
			_hex.add_child(_new_structure)
			_hex.structure = _new_structure
			_hex.structure._setup()
		StructureType.IMPASSABLE:
			print_rich(DEBUG_NAME,"SetStructure > Type = IMPASSABLE, creating a Impassable structure ")
			_new_structure = impassable_prefab.instantiate()
			_hex.add_child(_new_structure)
			_hex.structure = _new_structure
			_hex.structure._setup()
		StructureType.KISS_STATION:
			print_rich(DEBUG_NAME,"SetStructure > Type = KISS_STATION, creating a Kiss Station structure ")
			_new_structure = kiss_station_prefab.instantiate()
			_hex.add_child(_new_structure)
			_hex.structure = _new_structure
			_hex.structure._setup()
	
	#Temporary
	if _type != StructureType.CONSTRUCTION && _type != StructureType.IMPASSABLE && !_hex.structure.active:
		_hex.structure.assigned_workers = 1
		_hex.structure.activate()
	
	return true
