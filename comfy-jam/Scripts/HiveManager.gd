class_name HiveManager extends Node
const DEBUG_NAME : String = "[b][HiveManager][/b] "
static var instance : HiveManager = null

static var game_length : float = 360

static var game_time : float = 0


signal _on_game_time_finished
static func on_game_time_finished() -> Signal:
	return instance._on_game_time_finished


func _enter_tree() -> void:
	instance = self



func _ready() -> void:
	start_hive()


func start_hive() -> void:
	
	if !HexManager.initialise():
		push_error(DEBUG_NAME,"StartHive > ERROR, could not initialise HexManager :(")
	
	#royal_chambers = HexManager.royal_chambers_hex.structure
	


func _process(delta: float) -> void:
	
	game_time += delta
	
	if game_time >= game_length:
		_on_game_time_finished.emit()
