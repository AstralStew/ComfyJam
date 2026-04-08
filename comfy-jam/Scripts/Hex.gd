class_name Hex extends Node2D
var DEBUG_NAME : String = "[b][Hex("+name+")][/b] "



@export var coords : Vector2i = Vector2i(-1,-1) :
	get: return coords
	set(value):
		$TextureRect/Coords.text = (" " if value.x >= 0 else "") + str(value.x) + (" " if value.y >= 0 else "") + str(value.y)
		coords = value


signal hex_clicked


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	if randf() > 0.75: $TextureRect.self_modulate = Color(1.0, 0.867, 0.796, 1.0)


func _on_gui_input(event: InputEvent) -> void:
	if event.is_pressed():
		print_rich(DEBUG_NAME,"OnGuiInput > Mouse click recieved!")
		hex_clicked.emit()
