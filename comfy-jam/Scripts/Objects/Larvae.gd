class_name Larvae extends Node2D
var DEBUG_NAME : String :
	get: return "[b][" + name + "/Larvae][/b] "

var _sprite : Sprite2D = null
var _draggable : Draggable = null
var _fallable : Fallable = null
var _crawlable : Crawlable = null
@export var fall_on_setup : bool = false

@export var midpoint : int = 600
@export var floor_width : int = 30

@export var growth_per_nectar : float = 0.15
@export var chew_time_per_nectar : float = 2
@export var growth_per_pollen : float = 0.25
@export var chew_time_per_pollen : float = 3
@export var eat_cooldown : float = 5.0

@export_category("READ ONLY")
@export var growth : float = 0.0
@export var eating_on_cooldown : bool = false
@export var usable : bool = false :
	get: return !_draggable.dragging && !_fallable.falling

var can_eat : bool = false


signal on_dragged

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if !_setup_complete:
		setup()

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
	if _tween: return
	# Startup animation
	print_rich(DEBUG_NAME,"StartingAnimation > [color=cyan]Got here")
	var _starting_scale:Vector2 = scale
	var _scale_multiplier:float = 1.2
	_tween = create_tween().set_parallel(true)
	_tween.tween_property(self, "scale", scale * _scale_multiplier,_duration/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	_tween.tween_property(self, "scale", _starting_scale,_duration/2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT).set_delay(_duration/2)



func show_outline() -> void:
	_sprite.material = preload("res://Assets/Materials/selection_material.tres")

func hide_outline() -> void:
	_sprite.material = null

func drag_start() -> void:
	if _tween: _tween.kill()
	if !can_eat: can_eat = true
	
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
	if _draggable.dragging || _fallable.falling || eating_on_cooldown || !can_eat: return
	
	var _object : Node2D = _area.get_parent()
	
	if _object.is_in_group("Nectar"):
		var _nectar = (_object as Nectar)
		if _nectar.usable:
			_object.queue_free()
			eat_nectar()
		return
	
	if _object.is_in_group("Pollen"):
		var _pollen = (_object as Pollen)
		if _pollen.usable:
			_object.queue_free()
			eat_pollen()
		return

func eat_nectar() -> void:
	eating_on_cooldown = true
	
	_draggable.can_drag = false
	_crawlable.stop()
	
	_sprite.modulate = Color(0.953, 0.71, 0.659, 1.0)
	
	await get_tree().create_timer(chew_time_per_nectar).timeout
	growth += growth_per_nectar
	test_growth()
		
	_sprite.modulate = Color.WHITE
	
	_draggable.can_drag = true
	_crawlable.crawl(_sprite.flip_h)
	
	cooldown()
	

func eat_pollen() -> void:
	eating_on_cooldown = true
	
	_draggable.can_drag = false
	_crawlable.stop()
	
	_sprite.modulate = Color(0.953, 0.71, 0.659, 1.0)
	
	await get_tree().create_timer(chew_time_per_pollen).timeout
	growth += growth_per_pollen
	test_growth()
	
	_sprite.modulate = Color.WHITE
	
	_draggable.can_drag = true
	_crawlable.crawl(_sprite.flip_h)
	
	cooldown()

func cooldown() -> void:
	await get_tree().create_timer(eat_cooldown).timeout
	eating_on_cooldown = false

func test_growth() -> void:
	if growth >= 1.0:
		var _worker = ObjectManager.create_worker(global_position, true)
		queue_free()
