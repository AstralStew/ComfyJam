class_name Fallable extends Node
var _debug_name : String :
	get: return "{" + str(Time.get_ticks_msec()) + "} [" + get_parent().name + "/Fallable] "


@export var can_fall := false
@export var fall_speed : float = 0.2

#@export var floor_bounds_y : Vector2i = Vector2i(570,630)
@export var midpoint : int = 600
@export var floor_width : int = 30


var falling = false :
	get: return falling
	set(value):
		if !falling && value: on_falling_start.emit()
		if falling && !value: on_falling_end.emit()
		falling = value


signal on_falling_start
signal on_falling_end

#region Internal functions

#
#func _process(delta: float) -> void:
	#if falling:
		#_current_fall_speed += Vector2(0,fall_speed*delta)
		#(get_parent() as Node2D).position += _current_fall_speed

#endregion


func set_falling(_value:bool) -> void:
	
	if can_fall && _value:
		fall() 
	elif !_value:
		falling = false
		#_current_fall_speed = Vector2.ZERO

func fall() -> void:
	var _current_fall_speed := Vector2.ZERO
	var _floor_height := midpoint + (randi_range(-1,1) * randi() % floor_width) # randi_range(floor_bounds_y.x,floor_bounds_y.y)
	
	falling = true
	while(falling):
		_current_fall_speed += Vector2(0,fall_speed)
		(get_parent() as Node2D).global_position += _current_fall_speed
		if (get_parent() as Node2D).global_position.y >= _floor_height:
			(get_parent() as Node2D).global_position.y = _floor_height
			break
		await get_tree().process_frame
	falling = false
