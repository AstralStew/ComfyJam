class_name HiveManager extends Node
const DEBUG_NAME : String = "[b][HiveManager][/b] "
static var instance : HiveManager = null

static var chosen_seed : int = -1

@export var end_on_timeout := true

#region STRUCTURE UPGRADES

static var game_length : float = 360
static var max_number_of_each_object = 8

static var upgrade_global_speed_multiplier_levels : Array[float] = [1.0,1.05,1.1,1.15,1.2,1.3,1.5]
static var upgrade_global_speed_multiplier : float = 1.0


static var upgrade_starting_number_of_impassable_levels : Array[int] = [7,5,3,1]
static var upgrade_starting_number_of_impassable : int = 7								# Implemented
	
static var upgrade_starting_number_of_holes_levels : Array[int] = [1,3,5,7]
static var upgrade_starting_number_of_holes : int = 1									# Implemented
	
static var upgrade_starting_number_of_nurseries_levels : Array[int] = [1,3,5,7]
static var upgrade_starting_number_of_nurseries : int = 1								# Implemented
	
static var upgrade_starting_number_of_kiss_stations_levels : Array[int] = [0,1,2,3]
static var upgrade_starting_number_of_kiss_stations : int = 0							# Implemented
	
static var upgrade_starting_number_of_honeycombs_levels : Array[int] = [0,1,2,3]
static var upgrade_starting_number_of_honeycombs : int = 0								# Implemented
	
static var upgrade_starting_number_of_jelly_factories_levels : Array[int] = [0,1,2,3]
static var upgrade_starting_number_of_jelly_factories : int = 0						# Implemented
	
static var upgrade_starting_number_of_dancepads_levels : Array[int] = [0,1,2,3]
static var upgrade_starting_number_of_dancepads : int = 0								# Implemented

static var upgrade_starting_number_of_impassable_around_royal_chambers_levels : Array[int] = [4,3,2,0]
static var upgrade_starting_number_of_impassable_around_royal_chambers : int = 4


static var upgrade_hole_speed_multiplier_levels : Array[float] = [1.0,1.25,1.5,2]
static var upgrade_hole_speed_multiplier : float = 1.0									# Implemented
static var upgrade_hole_output_number_levels : Array[int] = [1,2]
static var upgrade_hole_output_number : int = 1										# Implemented
	
static var upgrade_jelly_factory_speed_multiplier_levels : Array[float] = [1.0,1.25,1.5,2]
static var upgrade_jelly_factory_speed_multiplier : float = 1.0						# Implemented

static var upgrade_nursery_speed_multiplier_levels : Array[float] = [1.0,1.25,1.5,2]
static var upgrade_nursery_speed_multiplier : float = 1.0								# Implemented

static var upgrade_kiss_station_speed_multiplier_levels : Array[float] = [1.0,1.25,1.5,2]
static var upgrade_kiss_station_speed_multiplier : float = 1.0							# Implemented
static var upgrade_kiss_station_chance_to_double_kiss_levels : Array[float] = [0,0.15,0.25,0.5]
static var upgrade_kiss_station_chance_to_double_kiss : float = 0.0
static var upgrade_kiss_station_cooldown_levels : Array[float] = [15.0,11.0,7.0,3.0]
static var upgrade_kiss_station_cooldown : float = 15.0								# Implemented

static var upgrade_dancepad_cooldown_levels : Array[float] = [15.0,11.0,7.0,3.0]
static var upgrade_dancepad_cooldown : float = 15.0									# Implemented

static var upgrade_construction_speed_multiplier_levels : Array[float] = [1.0,1.5,2.0,3.0]
static var upgrade_construction_speed_multiplier : float = 1.0							# Implemented

static var upgrade_honeycomb_capacity_levels : Array[int] = [3,5,7,9]
static var upgrade_honeycomb_capacity : int = 3										# Implemented

static var upgrade_royal_chambers_order_cooldown_levels : Array[float] = [30.0,25.0,20.0,15.0]
static var upgrade_royal_chambers_order_cooldown : float = 30.0						# Implemented

#endregion


#region OBJECT UPGRADES

static var upgrade_starting_number_of_larvae_levels : Array[int] = [0,2,4,7]
static var upgrade_starting_number_of_larvae : int = 0

static var upgrade_starting_number_of_nectar_levels : Array[int] = [1,3,5,8]
static var upgrade_starting_number_of_nectar : int = 1

static var upgrade_starting_number_of_pollen_levels : Array[int] = [1,3,5,8]
static var upgrade_starting_number_of_pollen : int = 1

static var upgrade_starting_number_of_royal_jelly_levels : Array[int] = [2,3,5,7]
static var upgrade_starting_number_of_royal_jelly : int = 2

static var upgrade_starting_number_of_honey_levels : Array[int] = [0,1,2,4]
static var upgrade_starting_number_of_honey : int = 1

static var upgrade_starting_number_of_workers_levels : Array[int] = [4,5,6,7]
static var upgrade_starting_number_of_workers : int = 4


static var upgrade_larvae_eating_speed_multiplier_levels : Array[float] = [1.0,1.25,1.5,2]
static var upgrade_larvae_eating_speed_multiplier : float = 1.0						# Implemented

static var upgrade_larvae_amount_of_food_needed_levels : Array[float] = [1.0,0.8,0.6,0.4]
static var upgrade_larvae_amount_of_food_needed : float = 1.0							# Implemented

static var upgrade_larvae_move_speed_levels : Array[float] = [1.0,0.7,0.4,0.1]
static var upgrade_larvae_move_speed : float = 1.0										# Implemented

#endregion



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
	if chosen_seed == -1:
		chosen_seed = randi() % 1000
	seed(chosen_seed)

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
		_game_finished = true
		if end_on_timeout:
			print_rich(DEBUG_NAME,"GAME FINISHED!!!")
			_on_hive_finish.emit()
		
		
