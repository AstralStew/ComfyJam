class_name Nectar extends Node2D
var DEBUG_NAME : String :
	get: return "[b][" + name + "/Nectar][/b] "

var _draggable : Draggable = null
var _fallable : Fallable = null
var _fall_on_setup : bool = false

signal on_move

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	_setup()

func _setup() -> void:
	_draggable = $Draggable
	_fallable = $Fallable
	
	_draggable.on_touching_floor.connect(_fallable.set_falling.bind(false))
	_draggable.on_drag_start.connect(_fallable.set_falling.bind(false))
	_draggable.on_drag_start.connect(drag_start)
	_draggable.on_drag_end.connect(_fallable.set_falling.bind(true))
	_draggable.on_drag_end.connect(drag_end)
	_draggable.on_drag_move.connect(on_move.emit)
	
	_fallable.falling = _fall_on_setup


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func drag_start() -> void:
	scale = Vector2(0.5,0.5)

func drag_end() -> void:
	scale = Vector2(1,1)
