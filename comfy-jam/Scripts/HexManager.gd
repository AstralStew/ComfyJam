class_name HexManager extends Node
const DEBUG_NAME : String = "[b][HexManager][/b] "

enum HexDirection {TopL,TopR,MidL,MidR,BotL,BotR}

static var instance : HexManager = null

@export var hex_prefab = preload("res://Scenes/hex.tscn")
@onready var hex_parent = $"../SubViewportContainer/SubViewport/Hexes"

@export var grid_height = 10
@export var grid_width = 10
@export var grid_spacing = 50
@export var hexgrid : Dictionary[int,Array] = {}


signal hex_clicked(hex)

func _enter_tree() -> void:
	instance = self

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
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
			# Create a hex
			_hex = hex_prefab.instantiate()
			_hex.name = "hex_" + str(_column) + "_" + str(_row)
			_hex.coords = Vector2i(_column,_row)
			_row_node.add_child(_hex)
			_hex.hex_clicked.connect(hex_clicked.emit.bind(_hex))
			
			# Set position if row is even
			#if _row % 2 == 0: _hex.position = Vector2(0.5+_column,_row) * grid_spacing
			# Set position if row is odd
			#else: _hex.position = Vector2(_column,_row) * grid_spacing
			_hex.position = Vector2(_column,0) * grid_spacing
			
			# Add hex to this row's column array
			_columns.append(_hex)
		hexgrid[_row] = _columns.duplicate()
		_columns.clear()
	
	hex_clicked.connect(test_hex)
	
	test()

func test_hex(_hex:Hex) -> void:
	print_rich(DEBUG_NAME,"TestHex > Testing hex '",_hex.name,"'...")
	print_rich(DEBUG_NAME,"TestHex > Adjacent hexes = ",get_adjacent_hexes(_hex))

func test() -> void:
	await get_tree().create_timer(1).timeout
	
	check_coords(Vector2i(-1,3))
	
	await get_tree().create_timer(0.5).timeout	
	
	check_coords(Vector2i(10,11))
	
	await get_tree().create_timer(0.5).timeout
	
	check_coords(Vector2i(4,6))
	
	await get_tree().create_timer(0.5).timeout
	
	get_adjacent_coord(Vector2i(4,6),HexDirection.TopL)
	
	


func check_coords(_coords:Vector2i) -> bool:
		# Make sure the coords exist on the grid
		if _coords.y < 0 || _coords.y >= hexgrid.size():
			print_rich(DEBUG_NAME,"CheckCoords > [color=ff0000] Bad row / y coords(",str(_coords.y),">",str(hexgrid.size()),"), returning false")
			return false
		if _coords.x < 0 || _coords.x >= hexgrid[_coords.y].size():
			print_rich(DEBUG_NAME,"CheckCoords > [color=ff0000] Bad column / x coords(",str(_coords.x),">",str(hexgrid[_coords.y].size()),"), returning false")
			return false
		print_rich(DEBUG_NAME,"CheckCoords > Coords(",str(_coords),") check out!")
		return true

func get_adjacent_coord(_coords:Vector2i,_direction:HexDirection) -> Vector2i:
	if !check_coords(_coords):
		print_rich(DEBUG_NAME,"GetAdjacentHex > [color=ff0000] Bad coords, returning invalid Vector2")
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
		print_rich(DEBUG_NAME,"GetAdjacentCoord > No hex at coords(",str(_coords+_dir),"), returning invalid Vector2")
		return Vector2i(-1,-1)
	
	print_rich(DEBUG_NAME,"GetAdjacentCoord > Success, returning coords(",str(_coords+_dir),")")
	return _coords+_dir




func get_hex(_coords:Vector2i) -> Hex:
	if !check_coords(_coords):
		print_rich(DEBUG_NAME,"GetHex > [color=ff0000] Bad coords, returning null")
		return null
	return hexgrid[_coords.y][_coords.x]


func get_adjacent_hex(_hex:Hex,_direction:HexDirection) -> Hex:
	return get_hex(get_adjacent_coord(_hex.coords,_direction))


func get_adjacent_hexes(_hex:Hex) -> Array[Hex]:
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


#
	#
	#if get_adjacent_hex(_hex,HexDirection.TopL) != null:
		#_adjacent_hexes.append(get_adjacent_hex(_hex,HexDirection.TopL))
	#
	#if get_adjacent_coord(_coords,HexDirection.TopL) != Vector2i(-1,-1):
		#_adjacent_hexes.append( get_hex(get_adjacent_coord(_coords,HexDirection.TopL)) )
	#if get_adjacent_coord(_coords,HexDirection.TopR) != Vector2i(-1,-1):
		#_adjacent_hexes.append( get_hex(get_adjacent_coord(_coords,HexDirection.TopR)) )
	#if get_adjacent_coord(_coords,HexDirection.MidL) != Vector2i(-1,-1):
		#_adjacent_hexes.append( get_hex(get_adjacent_coord(_coords,HexDirection.MidL)) )
	#if get_adjacent_coord(_coords,HexDirection.MidR) != Vector2i(-1,-1):
		#_adjacent_hexes.append( get_hex(get_adjacent_coord(_coords,HexDirection.MidR)) )
	#if get_adjacent_coord(_coords,HexDirection.BotL) != Vector2i(-1,-1):
		#_adjacent_hexes.append( get_hex(get_adjacent_coord(_coords,HexDirection.BotL)) )
	#if get_adjacent_coord(_coords,HexDirection.BotR) != Vector2i(-1,-1):
		#_adjacent_hexes.append( get_hex(get_adjacent_coord(_coords,HexDirection.BotR)) )
	#
