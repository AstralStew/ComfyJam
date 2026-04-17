class_name HiveManager extends Node
const DEBUG_NAME : String = "[b][HiveManager][/b] "
static var instance : HiveManager = null



static var game_length : float = 10

static var upgrade_global_speed_multiplier : float = 1.0

static var upgrade_starting_number_of_impassable : int = 7
static var upgrade_starting_number_of_holes : int = 1
static var upgrade_starting_number_of_nurseries : int = 1
static var upgrade_starting_number_of_kiss_stations : int = 0
static var upgrade_starting_number_of_honeycombs : int = 0
static var upgrade_starting_number_of_jelly_factories : int = 0
static var upgrade_starting_number_of_dancepads : int = 0

static var upgrade_starting_number_of_impassable_around_royal_chambers : int = 4

static var upgrade_hole_speed_multiplier : float = 1.0
static var upgrade_hole_output_number : int = 1

static var upgrade_jelly_factory_speed_multiplier : float = 1.0

static var upgrade_nursery_speed_multiplier : float = 1.0

static var upgrade_kiss_station_speed_multiplier : float = 1.0
static var upgrade_kiss_station_chance_to_double_kiss : float = 1.0
static var upgrade_kiss_station_cooldown : float = 15.0

static var upgrade_dancepad_cooldown : float = 15.0

static var upgrade_construction_speed_multiplier : float = 1.0

static var upgrade_honeycomb_capacity : int = 3

static var upgrade_royal_chambers_order_cooldown : float = 25.0








# READ ONLY



static var game_time : float = 0

var _game_finished : bool = false


signal _on_hive_start
static func on_hive_start() -> Signal:
	return instance._on_hive_start

signal _on_hive_finish
static func on_hive_finish() -> Signal:
	return instance._on_hive_finish


signal _on_wipe_scene
static func on_wipe_scene() -> Signal:
	return instance._on_wipe_scene

signal _on_restarting_scene
static func on_restarting_scene() -> Signal:
	return instance._on_restarting_scene


func reset() -> void:
	instance = self
	game_time = 0

func _enter_tree() -> void:
	reset()


func _ready() -> void:
	start_hive()


func start_hive() -> void:
	
	if !HexManager.initialise():
		push_error(DEBUG_NAME,"StartHive > ERROR, could not initialise HexManager :(")
	
	await get_tree().create_timer(0.1).timeout
	
	_on_hive_start.emit()
	

static func wipe_hive() -> void: instance._wipe_hive()
func _wipe_hive() -> void:
	var hive_nodes = $"../SubViewportContainer/SubViewport/HiveNodes"
	
	#print_rich("[color=pink]",DEBUG_NAME,"Queue free bout to happen")
	hive_nodes.queue_free()
	print_rich("[color=pink]",DEBUG_NAME,"Queue free just happened here")
	
	await get_tree().process_frame
	_on_wipe_scene.emit()
	

func _process(delta: float) -> void:
	
	game_time += delta
	
	if !_game_finished && game_time >= game_length:
		print_rich("[color=pink]",DEBUG_NAME,"GAME FINISHED!!!")
		_game_finished = true
		_on_hive_finish.emit()
