class_name Upgrade extends Node
var DEBUG_NAME : String  :
	get: return "[b][Upgrade("+name+")][/b] "
@export var debug : bool = false


signal upgrade

func _on_gui_input(event: InputEvent) -> void:
	
	if event is InputEventMouse:
		
		#if event.is_action_pressed("LeftClick"):
			#print_rich(DEBUG_NAME,"OnGuiInput > LeftClick pressed recieved!")
			#upgrade.emit()
		
		if event.is_action_released("LeftClick"):
			print_rich(DEBUG_NAME,"OnGuiInput > LeftClick released recieved!")
			upgrade.emit()
