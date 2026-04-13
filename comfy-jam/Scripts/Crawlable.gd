class_name Crawlable extends Node
var _debug_name : String :
	get: return "{" + str(Time.get_ticks_msec()) + "} [" + get_parent().name + "/Crawlable] "



@export var crawl_speed : Vector2 = Vector2(0.4,0.1)

@export var floor_bounds_x : Vector2i = Vector2i(100,540)
#@export var floor_bounds_y : Vector2i = Vector2i(570,630)

@export var midpoint : int = 600
@export var floor_width : int = 30

var crawling = false :
	get: return crawling
	set(value):
		if !crawling && value: on_crawling_start.emit()
		if crawling && !value: on_crawling_end.emit()
		crawling = value

#var _current_fall_speed : Vector2 = Vector2.ZERO

signal on_crawling_start
signal on_crawling_end
signal on_crawling_flip(moving_right)

#region Internal functions


func crawl(_moving_right:bool) -> void:
	crawling = true
	var _vert : float = (get_parent() as Node2D).global_position.y
	var _move_vector := Vector2.ZERO
	while(crawling):
		_vert += crawl_speed.y * get_process_delta_time()
		_move_vector = Vector2((1 if _moving_right else -1) * crawl_speed.x * get_process_delta_time(),0)
		(get_parent() as Node2D).position = Vector2(_move_vector.x + (get_parent() as Node2D).position.x,midpoint + (sin(_vert) * floor_width))
		# If positive and beyond bounds
		if !_moving_right && (get_parent() as Node2D).position.x <= floor_bounds_x.x || _moving_right && (get_parent() as Node2D).position.x >= floor_bounds_x.y:
			_moving_right = !_moving_right
			on_crawling_flip.emit(_moving_right)
		
		await get_tree().process_frame
	crawling = false


func stop() -> void:
	crawling = false

#endregion
