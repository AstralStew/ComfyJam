class_name Nectar extends Node2D
var DEBUG_NAME : String :
	get: return "[b][" + name + "/Nectar][/b] "

var _sprite : Sprite2D = null
var _draggable : Draggable = null
var _fallable : Fallable = null
@export var fall_on_setup : bool = false

@export_category("READ ONLY")
@export var usable : bool = false :
	get: return !_fallable.falling #!_draggable.dragging && !_fallable.falling

signal on_dragged

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !_setup_complete: setup()

var _setup_complete := false
func setup() -> void:
	_sprite = $Sprite2D
	_draggable = $Draggable
	_fallable = $Fallable
	
	_draggable.on_area_entered.connect(area_entered)
	_draggable.on_drag_start.connect(_fallable.set_falling.bind(false))
	_draggable.on_drag_start.connect(drag_start)
	_draggable.on_drag_end.connect(_fallable.set_falling.bind(true))
	_draggable.on_drag_end.connect(drag_end)
	_draggable.on_drag_move.connect(on_dragged.emit)
	_draggable.on_hover_start.connect(hover_start)
	_draggable.on_hover_end.connect(hover_end)
	
	_fallable.on_falling_start.connect(fall_start)
	_fallable.on_falling_end.connect(fall_end)
	_fallable.set_falling(fall_on_setup)
	#_fallable.falling = _fall_on_setup
	
	_setup_complete = true



func drag_start() -> void:
	scale = Vector2(0.8,0.8)

func drag_end() -> void:
	scale = Vector2(1,1)

func fall_start() -> void:
	_draggable.can_drag = false

func fall_end() -> void:
	_draggable.can_drag = true

func hover_start() -> void:
	_sprite.material = preload("res://Assets/Materials/selection_material.tres")
	
func hover_end() -> void:
	_sprite.material = null

func area_entered(_area:Area2D) -> void:
	if _draggable.dragging: return
	
	var _object : Node2D = _area.get_parent()
	
	if _object.is_in_group("Floor"):
		_fallable.set_falling(false)
