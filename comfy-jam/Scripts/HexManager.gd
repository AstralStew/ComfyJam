class_name HexManager extends Node
const DEBUG_NAME : String = "[b][HexManager][/b] "

@export var debug : bool = false

enum HexDirection {TopL,TopR,MidL,MidR,BotL,BotR}

static var instance : HexManager = null

@export var hex_prefab = preload("res://Scenes/hex.tscn")
var hex_parent : Node = null

@export var grid_height = 10
@export var grid_width = 10
@export var grid_spacing = 50
@export var hexgrid : Dictionary[int,Array] = {}

#@export var starting_impassable = 0
#@export var starting_empty_holes = 0
#@export var starting_holes_with_workers = 0
#@export var starting_nurseries_with_workers = 0
#@export var starting_honeycomb_with_workers = 0


@export_category("READ ONLY")
static var last_hovered_hex : Hex = null
#static var royal_chambers_hex : Hex = null

signal on_hex_clicked(hex)
signal on_hex_unclicked(hex)


func reset() -> void:
	instance = self
	last_hovered_hex = null

func _enter_tree() -> void:
	reset() 

# Called when the node enters the scene tree for the first time.
static func initialise() -> bool: return instance._initialise()
func _initialise() -> bool:
	
	hex_parent = $"../SubViewportContainer/SubViewport/HiveNodes/Hexes"
	
	var _columns : Array[Node2D] = []
	var _row_node : Node2D = null
	var _hex : Hex = null
	for _row in grid_height:
		# Create the row
		_row_node = Node2D.new()
		_row_node.name = "row_" + str(_row)
		hex_parent.add_child(_row_node)
		# Set position if row is even
		if _row % 2 == 0: _row_node.position = Vector2(0.5,0.85*_row) * grid_spacing
		# Set position if row is odd
		else: _row_node.position = Vector2(0,0.85*_row) * grid_spacing
		
		for _column in grid_width:
			# Create a hex inside the row
			_hex = hex_prefab.instantiate()
			_hex.name = "hex_" + str(_column) + "_" + str(_row)
			_hex.coords = Vector2i(_column,_row)
			_row_node.add_child(_hex)
			_hex.position = Vector2(_column,0) * grid_spacing
			_hex.on_hex_clicked.connect(on_hex_clicked.emit.bind(_hex))
			_hex.on_hex_unclicked.connect(on_hex_unclicked.emit.bind(_hex))
			
			# Add hex to this row's column array
			_columns.append(_hex)
		# Add an extra hex if this is an odd row
		if _row % 2 != 0:
			# Create a hex inside the row
			_hex = hex_prefab.instantiate()
			_hex.name = "hex_" + str(grid_width) + "_" + str(_row)
			_hex.coords = Vector2i(grid_width,_row)
			_row_node.add_child(_hex)
			_hex.position = Vector2(grid_width,0) * grid_spacing
			_hex.on_hex_clicked.connect(on_hex_clicked.emit.bind(_hex))
			_hex.on_hex_unclicked.connect(on_hex_unclicked.emit.bind(_hex))
			
			# Add hex to this row's column array
			_columns.append(_hex)
		
		hexgrid[_row] = _columns.duplicate()
		_columns.clear()
	
	
	# Add some specific hexes
	
	
	if debug: print_rich(DEBUG_NAME,"Ready > Adding the Royal Chambers, populating hexes around it with Impassable")
	_hex = get_random_hex(true)
	StructureManager.set_structure(_hex,StructureManager.StructureType.ROYAL_CHAMBERS)
	_hex.structure.activate()
	var _adjacent_hexes = get_adjacent_hexes(_hex)
	_adjacent_hexes.shuffle()
	for i in _adjacent_hexes.size():
		if i == 0 || i == 1: continue
		StructureManager.set_structure(_adjacent_hexes[i],StructureManager.StructureType.IMPASSABLE)
		if debug: print_rich(DEBUG_NAME,"Ready > Created Impassable around Royal Chambers")
	#royal_chambers_hex = _hex
	
	for i in HiveManager.upgrade_starting_number_of_impassable:
		StructureManager.set_structure(get_random_hex(true),StructureManager.StructureType.IMPASSABLE)
		if debug: print_rich(DEBUG_NAME,"Ready > Created starting impassable")
	
	#for i in starting_empty_holes:
		#StructureManager.set_structure(get_random_hex(true),StructureManager.StructureType.HOLE)
		#if debug: print_rich(DEBUG_NAME,"Ready > Created starting empty hole")
	
	for i in HiveManager.upgrade_starting_number_of_holes:
		_hex = get_random_hex(true)
		StructureManager.set_structure(_hex,StructureManager.StructureType.HOLE)
		_hex.structure.assigned_workers = 1
		_hex.structure.activate()
		if debug: print_rich(DEBUG_NAME,"Ready > Created starting hole with worker ("+_hex.name+")")
	
	for i in HiveManager.upgrade_starting_number_of_nurseries:
		_hex = get_random_hex(true)
		StructureManager.set_structure(_hex,StructureManager.StructureType.NURSERY)
		_hex.structure.assigned_workers = 1
		_hex.structure.activate()
		if debug: print_rich(DEBUG_NAME,"Ready > Created starting nursery with worker ("+_hex.name+")")
	
	for i in HiveManager.upgrade_starting_number_of_honeycombs:
		_hex = get_random_hex(true)
		StructureManager.set_structure(_hex,StructureManager.StructureType.HONEYCOMB)
		_hex.structure.assigned_workers = 1
		_hex.structure.activate()
		if debug: print_rich(DEBUG_NAME,"Ready > Created starting honeycomb with worker ("+_hex.name+")")
	
	for i in HiveManager.upgrade_starting_number_of_jelly_factories:
		_hex = get_random_hex(true)
		StructureManager.set_structure(_hex,StructureManager.StructureType.HONEYCOMB)
		_hex.structure.assigned_workers = 1
		_hex.structure.activate()
		if debug: print_rich(DEBUG_NAME,"Ready > Created starting jelly factory with worker ("+_hex.name+")")
	
	for i in HiveManager.upgrade_starting_number_of_kiss_stations:
		_hex = get_random_hex(true)
		StructureManager.set_structure(_hex,StructureManager.StructureType.KISS_STATION)
		_hex.structure.assigned_workers = 1
		_hex.structure.activate()
		if debug: print_rich(DEBUG_NAME,"Ready > Created starting kiss station with worker ("+_hex.name+")")
	
	for i in HiveManager.upgrade_starting_number_of_dancepads:
		_hex = get_random_hex(true)
		StructureManager.set_structure(_hex,StructureManager.StructureType.DANCEPAD)
		_hex.structure.assigned_workers = 1
		_hex.structure.activate()
		if debug: print_rich(DEBUG_NAME,"Ready > Created starting dancepad with worker ("+_hex.name+")")
	
	
	on_hex_clicked.connect(on_click_hex)
	on_hex_unclicked.connect(on_unclick_hex)
	
	return true


func on_click_hex(_hex:Hex) -> void:
	if debug: print_rich(DEBUG_NAME,"OnClickHex > Clicked hex '",_hex.name,"' (does nothing)")
	#print_rich(DEBUG_NAME,"TestHex > Adjacent hexes = ",get_adjacent_hexes(_hex))
	

func on_unclick_hex(_hex:Hex) -> void:
	if debug: print_rich(DEBUG_NAME,"TestHex > Unlicked hex '",_hex.name,"', showing tooltip")
	Tooltip.set_tooltip_type(Tooltip.TooltipType.HEX,_hex)
	#if (SelectionManager.current_selection as WorkerBee) != null:
		#BuildMenu.build_structure(_hex)

#func test() -> void:
	#await get_tree().create_timer(1).timeout
	#
	#check_coords(Vector2i(-1,3))
	#
	#await get_tree().create_timer(0.5).timeout	
	#
	#check_coords(Vector2i(10,11))
	#
	#await get_tree().create_timer(0.5).timeout
	#
	#check_coords(Vector2i(4,6))
	#
	#await get_tree().create_timer(0.5).timeout
	#
	#get_adjacent_coord(Vector2i(4,6),HexDirection.TopL)


func get_random_hex(empty_only:bool=false) -> Hex:
	
	if empty_only:
		var _hex : Hex = null
		while _hex == null:
			_hex = hexgrid[randi() % hexgrid.size()].pick_random()
			if debug: print_rich(DEBUG_NAME,"GetRandomHex > Hex is still null, checking hex("+_hex.name+")")
			if _hex.structure == null:
				if debug: print_rich(DEBUG_NAME,"GetRandomHex > Hex("+_hex.name+") structure is null! Returning this hex...")
				return _hex
			else: _hex = null
	
	if debug: print_rich(DEBUG_NAME,"GetRandomHex > Returning any random hex")
	return hexgrid[randi() % hexgrid.size()].pick_random()
	


#region  Coords

func check_coords(_coords:Vector2i) -> bool:
		# Make sure the coords exist on the grid
		if _coords.y < 0 || _coords.y >= hexgrid.size():
			if debug: print_rich(DEBUG_NAME,"CheckCoords > [color=ff0000] Bad row / y coords(",str(_coords.y),">",str(hexgrid.size()),"), returning false")
			return false
		if _coords.x < 0 || _coords.x >= hexgrid[_coords.y].size():
			if debug: print_rich(DEBUG_NAME,"CheckCoords > [color=ff0000] Bad column / x coords(",str(_coords.x),">",str(hexgrid[_coords.y].size()),"), returning false")
			return false
		if debug: print_rich(DEBUG_NAME,"CheckCoords > Coords(",str(_coords),") check out!")
		return true

func get_adjacent_coord(_coords:Vector2i,_direction:HexDirection) -> Vector2i:
	if !check_coords(_coords):
		if debug: print_rich(DEBUG_NAME,"GetAdjacentHex > [color=ff0000] Bad coords, returning invalid Vector2")
		return Vector2i(-1,-1)
	
	var _dir : Vector2i = Vector2i.ZERO
	var _even : bool = _coords.y % 2 == 0
	
	match _direction:
		HexDirection.TopL:
			if _even: _dir += Vector2i(0,-1)
			else: _dir += Vector2i(-1,-1)
		HexDirection.TopR:
			if _even: _dir += Vector2i(1,-1)
			else: _dir += Vector2i(0,-1)
		HexDirection.MidL:
			_dir += Vector2i(-1,0)
		HexDirection.MidR:
			_dir += Vector2i(1,0)
		HexDirection.BotL:
			if _even: _dir += Vector2i(0,1)
			else: _dir += Vector2i(-1,1)
		HexDirection.BotR:
			if _even: _dir += Vector2i(1,1)
			else: _dir += Vector2i(0,1)
	
	if !check_coords(_coords+_dir):
		if debug: print_rich(DEBUG_NAME,"GetAdjacentCoord > No hex at coords(",str(_coords+_dir),"), returning invalid Vector2")
		return Vector2i(-1,-1)
	
	if debug: print_rich(DEBUG_NAME,"GetAdjacentCoord > Success, returning coords(",str(_coords+_dir),")")
	return _coords+_dir




func get_hex(_coords:Vector2i) -> Hex:
	if !check_coords(_coords):
		if debug: print_rich(DEBUG_NAME,"GetHex > [color=ff0000] Bad coords, returning null")
		return null
	return hexgrid[_coords.y][_coords.x]


static func get_adjacent_hex(_hex:Hex,_direction:HexDirection) -> Hex:
	return instance.get_hex(instance.get_adjacent_coord(_hex.coords,_direction))


static func get_adjacent_hexes(_hex:Hex) -> Array[Hex]:
	var _coords = _hex.coords
	
	var _adjacent_hexes : Array[Hex] = []
	var _adjacent_hex : Hex = null
	
	_adjacent_hex = get_adjacent_hex(_hex,HexDirection.TopL)
	if _adjacent_hex != null: _adjacent_hexes.append(_adjacent_hex)
	
	_adjacent_hex = get_adjacent_hex(_hex,HexDirection.TopR)
	if _adjacent_hex != null: _adjacent_hexes.append(_adjacent_hex)
	
	_adjacent_hex = get_adjacent_hex(_hex,HexDirection.MidL)
	if _adjacent_hex != null: _adjacent_hexes.append(_adjacent_hex)
	
	_adjacent_hex = get_adjacent_hex(_hex,HexDirection.MidR)
	if _adjacent_hex != null: _adjacent_hexes.append(_adjacent_hex)
	
	_adjacent_hex = get_adjacent_hex(_hex,HexDirection.BotL)
	if _adjacent_hex != null: _adjacent_hexes.append(_adjacent_hex)
	
	_adjacent_hex = get_adjacent_hex(_hex,HexDirection.BotR)
	if _adjacent_hex != null: _adjacent_hexes.append(_adjacent_hex)
	
	return _adjacent_hexes


#endregion
