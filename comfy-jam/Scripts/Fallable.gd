class_name Fallable extends Node
var _debug_name : String :
	get: return "{" + str(Time.get_ticks_msec()) + "} [" + get_parent().name + "/Fallable] "


@export var can_fall := false
@export var _fall_speed : float = 0.2

var falling = false 

var _current_fall_speed : Vector2 = Vector2.ZERO

#region Internal functions

#func _ready() -> void:
	#falling = can_fall

func _process(delta: float) -> void:
	if falling:
		_current_fall_speed += Vector2(0,_fall_speed)
		(get_parent() as Node2D).position += _current_fall_speed

#endregion


func set_falling(_value:bool) -> void:
	if can_fall && _value:
		falling = true
		_current_fall_speed = Vector2.ZERO
	elif !_value:
		falling = false
		_current_fall_speed = Vector2.ZERO

#: 
	#get: return falling
	#set(value):
		#if !falling && value:
			#on_start_fall.emit()
		#elif falling && !value:
			#on_land.emit()
		#falling = value
