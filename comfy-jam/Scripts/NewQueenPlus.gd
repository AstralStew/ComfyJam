class_name NewQueenPlus extends Node
const DEBUG_NAME : String = "[b][NewQueenPlus][/b] "
@export var debug : bool = false

@onready var background : Panel 

@export var transition_time : float = 1.0
@export var transition_start_pos : Vector2 = Vector2.ZERO
@export var transition_mid_pos : Vector2 = Vector2.ZERO
@export var transition_end_pos : Vector2 = Vector2.ZERO

var wipe_tween : Tween = null

func _enter_tree() -> void:
	HiveManager.on_hive_start().connect(start_wipe)
	HiveManager.on_hive_finish().connect(end_wipe)
	
	background = $Background
	
	#background.position = transition_mid_pos
	

func start_wipe() -> void:
	if wipe_tween: wipe_tween.kill()
	
	
	await get_tree().process_frame
	wipe_tween = create_tween().set_parallel()
	wipe_tween.tween_property(background,"position",transition_end_pos,transition_time).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await get_tree().create_timer(transition_time,true).timeout

	background.visible = false


func end_wipe() -> void:
	if wipe_tween: wipe_tween.kill()
	
	await get_tree().process_frame
	background.position = transition_start_pos
	background.visible = true
	
	wipe_tween = create_tween().set_parallel()
	wipe_tween.tween_property(background,"position",transition_mid_pos,transition_time)
	await get_tree().create_timer(transition_time,true).timeout
	
	await get_tree().create_timer(1).timeout
	
	HiveManager.wipe_hive()
	
	await HiveManager.on_wipe_scene()
	
	$MarginContainer/VBoxContainer/MoveToNextHive.visible = true


func _on_button_pressed() -> void:
	
	
	await get_tree().process_frame
	get_tree().call_deferred("reload_current_scene")
	#.reload_current_scene()


#region STRUCTURE UPGRADE FUNCTIONS


func advance_upgrade_level(_current_value:Variant,_level_list:Array) -> Variant:
	
	var _level = _level_list.find(_current_value)
	
	if _level == -1:
		push_error(DEBUG_NAME,"AdvanceUpgradeFloatLevel > Could not find value '"+str(_current_value)+"' :(")
		return -1
	elif _level == _level_list.size() - 1:
		if debug: print_rich(DEBUG_NAME,"[color=orange]AdvanceUpgradeFloatLevel > Already at max level! Cancelling.")
		return -1
	
	if debug: print_rich(DEBUG_NAME,"AdvanceUpgradeFloatLevel > Success! Upgrading to level " + str(_level + 1))
	return _level_list[_level + 1]


func upgrade_global_speed_multiplier_level() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeGlobalSpeedMultiplierLevel > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_global_speed_multiplier,HiveManager.upgrade_global_speed_multiplier_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeGlobalSpeedMultiplierLevel > Success! New value = " + str(_new_value))
		HiveManager.upgrade_global_speed_multiplier = _new_value


func upgrade_starting_number_of_impassable_level() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfImpassableLevels > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_impassable,HiveManager.upgrade_starting_number_of_impassable_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfImpassableLevels > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_impassable = _new_value


func upgrade_starting_number_of_holes_level() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfHoles > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_holes,HiveManager.upgrade_starting_number_of_holes_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfHoles > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_holes = _new_value


func upgrade_hole_speed_multiplier() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeholeSpeedMultiplier > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_hole_speed_multiplier,HiveManager.upgrade_hole_speed_multiplier_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeholeSpeedMultiplier > Success! New value = " + str(_new_value))
		HiveManager.upgrade_hole_speed_multiplier = _new_value


func upgrade_hole_output_number() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeholeOutputNumber > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_hole_output_number,HiveManager.upgrade_hole_output_number_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeholeOutputNumber > Success! New value = " + str(_new_value))
		HiveManager.upgrade_hole_output_number = _new_value





func set_upgrade_starting_number_of_nurseries(_value : int = 1) -> void:
	HiveManager.upgrade_starting_number_of_nurseries = _value

func set_upgrade_nursery_speed_multiplier(_value : float = 1.0) -> void:
	HiveManager.upgrade_nursery_speed_multiplier = _value



func set_upgrade_starting_number_of_jelly_factories(_value : int = 0) -> void:
	HiveManager.upgrade_starting_number_of_jelly_factories = _value

func set_upgrade_jelly_factory_speed_multiplier(_value : float = 1.0) -> void:
	HiveManager.upgrade_jelly_factory_speed_multiplier = _value



func set_upgrade_starting_number_of_kiss_stations(_value : int = 0) -> void:
	HiveManager.upgrade_starting_number_of_kiss_stations = _value

func set_upgrade_kiss_station_speed_multiplier(_value : float = 1.0) -> void:
	HiveManager.upgrade_kiss_station_speed_multiplier = _value

func set_upgrade_kiss_station_chance_to_double_kiss(_value : float = 1.0) -> void:
	HiveManager.upgrade_kiss_station_chance_to_double_kiss = _value
	
func set_upgrade_kiss_station_cooldown(_value : float = 15.0) -> void:
	HiveManager.upgrade_kiss_station_cooldown = _value


func set_upgrade_starting_number_of_honeycombs(_value : int = 0) -> void:
	HiveManager.upgrade_starting_number_of_honeycombs = _value

func set_upgrade_honeycomb_capacity(_value : int = 3) -> void:
	HiveManager.upgrade_honeycomb_capacity = _value



func set_upgrade_starting_number_of_dancepads(_value : int = 0) -> void:
	HiveManager.upgrade_starting_number_of_dancepads = _value

func set_upgrade_dancepad_cooldown(_value : float = 15.0) -> void:
	HiveManager.upgrade_dancepad_cooldown = _value



func set_upgrade_construction_speed_multiplier(_value : float = 1.0) -> void:
	HiveManager.upgrade_construction_speed_multiplier = _value



func set_upgrade_starting_number_of_impassable_around_royal_chambers(_value : int = 4) -> void:
	HiveManager.upgrade_starting_number_of_impassable_around_royal_chambers = _value

func set_upgrade_royal_chambers_order_cooldown(_value : float = 25.0) -> void:
	HiveManager.upgrade_royal_chambers_order_cooldown = _value

#endregion


#region OBJECT UPGRADE FUNCTIONS

func set_upgrade_starting_number_of_larvae(_value : int = 0) -> void:
	HiveManager.upgrade_starting_number_of_larvae = _value
	
func set_upgrade_starting_number_of_nectar(_value : int = 1) -> void:
	HiveManager.upgrade_starting_number_of_nectar = _value
	
func set_upgrade_starting_number_of_pollen(_value : int = 1) -> void:
	HiveManager.upgrade_starting_number_of_pollen = _value
	
func set_upgrade_starting_number_of_royal_jelly(_value : int = 2) -> void:
	HiveManager.upgrade_starting_number_of_royal_jelly = _value
	
func set_upgrade_starting_number_of_honey(_value : int = 0) -> void:
	HiveManager.upgrade_starting_number_of_honey = _value
	
func set_upgrade_starting_number_of_workers(_value : int = 4) -> void:
	HiveManager.upgrade_starting_number_of_workers = _value


func set_upgrade_larvae_eating_speed_multiplier(_value : float = 1.0) -> void:
	HiveManager.upgrade_larvae_eating_speed_multiplier = _value
	
func set_upgrade_larvae_amount_of_food_needed(_value : float = 1.0) -> void:
	HiveManager.upgrade_larvae_amount_of_food_needed = _value
	
func set_upgrade_larvae_move_speed(_value : float = 1.0) -> void:
	HiveManager.upgrade_larvae_move_speed = _value

#endregion
