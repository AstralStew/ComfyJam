class_name WorkerBee extends Node2D
var DEBUG_NAME : String :
	get: return "[b][" + name + "/WorkerBee][/b] "

var free_standing : bool = false

var _sprite : Sprite2D = null
var _draggable : Draggable = null
var _fallable : Fallable = null
var _crawlable : Crawlable = null
@export var fall_on_setup : bool = false

@export var midpoint : int = 600
@export var floor_width : int = 30

@export_category("READ ONLY")
@export var usable : bool = false :
	get: return !_draggable.dragging && !_fallable.falling

signal on_dragged

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !_setup_complete: setup()

var _setup_complete := false
func setup() -> void:
	_sprite = $Sprite2D
	_draggable = $Draggable
	_fallable = $Fallable
	_crawlable = $Crawlable
	
	_draggable.on_area_entered.connect(area_entered)
	_draggable.on_drag_start.connect(_fallable.set_falling.bind(false))
	_draggable.on_drag_start.connect(drag_start)
	_draggable.on_drag_end.connect(_fallable.set_falling.bind(true))
	_draggable.on_drag_end.connect(drag_end)
	_draggable.on_hover_start.connect(hover_start)
	_draggable.on_hover_end.connect(hover_end)
	
	_fallable.on_falling_start.connect(fall_start)
	_fallable.on_falling_end.connect(fall_end)
	_fallable.set_falling(fall_on_setup)
	_fallable.midpoint = midpoint
	_fallable.floor_width = floor_width
	
	_crawlable.on_crawling_start.connect(crawl_start)
	_crawlable.on_crawling_start.connect(crawl_end)
	_crawlable.on_crawling_flip.connect(crawl_flip)
	_crawlable.midpoint = midpoint
	_crawlable.floor_width = floor_width
	
	_setup_complete = true


var _tween : Tween
func spawning_animation(_duration:float=1.0) -> void:
	# Startup animation
	print_rich(DEBUG_NAME,"StartingAnimation > [color=cyan]Got here")
	var _starting_scale:Vector2 = scale
	var _scale_multiplier:float = 1.15
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "scale", scale * _scale_multiplier,_duration/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "scale", _starting_scale,_duration/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT).set_delay(_duration/2)


func show_outline() -> void:
	_sprite.material = preload("res://Assets/Materials/selection_material.tres")

func hide_outline() -> void:
	_sprite.material = null

func drag_start() -> void:
	if !free_standing: ObjectManager.free_stand_object(self)
	
	scale = Vector2(0.69,0.69)
	_crawlable.stop()
	_sprite.flip_h = randi() % 2 == 0
	show_outline()
	on_dragged.emit()

func drag_end() -> void:
	scale = Vector2(1,1)
	hide_outline()

func fall_start() -> void:
	_draggable.can_drag = false

func fall_end() -> void:
	_draggable.can_drag = true
	_crawlable.crawl(_sprite.flip_h)

func crawl_start() -> void:
	pass

func crawl_flip(_moving_right:bool) -> void:
	_sprite.flip_h = _moving_right

func crawl_end() -> void:
	pass

func hover_start() -> void:
	if self != SelectionManager.current_selection:
		show_outline()
	
func hover_end() -> void:
	if self != SelectionManager.current_selection:
		hide_outline()

func area_entered(_area:Area2D) -> void:
	if _draggable.dragging: return
	
	var _object : Node2D = _area.get_parent()
	print_rich(DEBUG_NAME,"AreaEntered > Area parent = '"+_object.name+"'")
	
