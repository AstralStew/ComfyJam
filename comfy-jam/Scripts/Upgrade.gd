class_name Upgrade extends Control
var DEBUG_NAME : String  :
	get: return "[b][Upgrade("+name+")][/b] "
@export var debug : bool = false


@export var upgrade_type : NewQueenPlus.Upgrades = NewQueenPlus.Upgrades.upgrade_global_speed_multiplier


@export_category("READ ONLY")
@export var locked : bool = false


signal perform_upgrade(type)


func _ready() -> void:
	NewQueenPlus.register_upgrade_button(self,upgrade_type)

func _on_gui_input(event: InputEvent) -> void:
	if locked: return
	
	if event is InputEventMouse:
		
		#if event.is_action_pressed("LeftClick"):
			#print_rich(DEBUG_NAME,"OnGuiInput > LeftClick pressed recieved!")
			#upgrade.emit()
		
		if event.is_action_released("LeftClick"):
			print_rich(DEBUG_NAME,"OnGuiInput > LeftClick released recieved!")
			upgrade()

func upgrade() -> void:
	perform_upgrade.emit(upgrade_type)
	
	#ScoreMeter.instance.remove_score_hex()


func disable() -> void:
	locked = true
	modulate = Color(0.42,0.42,0.42)
