class_name NewQueenPlus extends Node
const DEBUG_NAME : String = "[b][NewQueenPlus][/b] "
static var instance : NewQueenPlus = null

enum Upgrades {
	upgrade_global_speed_multiplier,
	upgrade_starting_number_of_impassable,
	upgrade_starting_number_of_holes,
	upgrade_hole_speed_multiplier,
	upgrade_hole_output_number,
	upgrade_starting_number_of_nurseries,
	upgrade_nursery_speed_multiplier,
	upgrade_starting_number_of_jelly_factories,
	upgrade_jelly_factory_speed_multiplier,
	upgrade_starting_number_of_kiss_stations,
	upgrade_kiss_station_speed_multiplier,
	upgrade_kiss_station_chance_to_double_kiss,
	upgrade_kiss_station_cooldown,
	upgrade_starting_number_of_honeycombs,
	upgrade_honeycomb_capacity,
	upgrade_starting_number_of_dancepads,
	upgrade_dancepad_cooldown,
	upgrade_construction_speed_multiplier,
	upgrade_starting_number_of_impassable_around_royal_chambers,
	upgrade_royal_chambers_order_cooldown,
	upgrade_starting_number_of_larvae,
	upgrade_starting_number_of_nectar,
	upgrade_starting_number_of_pollen,
	upgrade_starting_number_of_royal_jelly,
	upgrade_starting_number_of_honey,
	upgrade_starting_number_of_workers,
	upgrade_larvae_amount_of_food_needed,
	upgrade_larvae_eating_speed_multiplier,
	upgrade_larvae_move_speed,
}

@export var debug : bool = false

@onready var background : Panel 
@onready var upgrade_screen : MarginContainer

@export var transition_time : float = 1.0
@export var transition_start_pos : Vector2 = Vector2.ZERO
@export var transition_mid_pos : Vector2 = Vector2.ZERO
@export var transition_end_pos : Vector2 = Vector2.ZERO

var wipe_tween : Tween = null

func _enter_tree() -> void:
	instance = self
	HiveManager.on_hive_start().connect(start_wipe)
	HiveManager.on_hive_finish().connect(end_wipe)
	
	background = $Background
	upgrade_screen = $UpgradeScreen
	
	#background.position = transition_mid_pos
	

func start_wipe() -> void:
	if wipe_tween: wipe_tween.kill()
	
	upgrade_screen.visible = false
	
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
	
	for _upgrade in _upgrade_buttons:
		reset_upgrade(_upgrade)
	
	check_meta_points()
	
	upgrade_screen.visible = true


func _on_restart_scene_with_same_seed() -> void:
	
	background.position = transition_start_pos
	background.visible = true
	
	wipe_tween = create_tween().set_parallel()
	wipe_tween.tween_property(background,"position",transition_mid_pos,transition_time/3)
	await get_tree().create_timer(transition_time/3,true).timeout
	
	await get_tree().process_frame
	get_tree().call_deferred("reload_current_scene")
	


func _on_button_pressed() -> void:
	
	HiveManager.chosen_seed = randi() % 1000
	await get_tree().process_frame
	get_tree().call_deferred("reload_current_scene")
	#.reload_current_scene()


#region STRUCTURE UPGRADE FUNCTIONS

signal out_of_meta_points

var _upgrade_buttons : Dictionary[Upgrades,Upgrade]

static func register_upgrade_button(_upgrade_button:Upgrade,_type:Upgrades) -> bool:
	if instance._upgrade_buttons.has(_type) && instance._upgrade_buttons[_type] != null:
		push_error(DEBUG_NAME,"RegisterUpgrade > Upgrade '"+Upgrades.keys()[_type]+"' already registered!")
		return false
	
	instance._upgrade_buttons[_type] = _upgrade_button
	_upgrade_button.perform_upgrade.connect(instance.advance_upgrade)
	instance.out_of_meta_points.connect(_upgrade_button.disable)
	
	return true


func reset_upgrade(_upgrade_type:Upgrades) -> void:
	var _level_list : Array = HiveManager.instance.get(Upgrades.keys()[_upgrade_type]+"_levels")
	var _level = _level_list.find(HiveManager.instance.get(Upgrades.keys()[_upgrade_type]))
	
	if _level == -1:
		push_error(DEBUG_NAME,"ResetUpgrade > Could not find upgrade '"+Upgrades.keys()[_upgrade_type]+"' :(")
		return 
	
	if debug: print_rich(DEBUG_NAME,"ResetUpgrade > Resetting upgrade " + str(Upgrades.keys()[_upgrade_type]))
	HiveManager.instance.set(Upgrades.keys()[_upgrade_type],_level_list[0])
	

func check_meta_points() -> bool:
	if ScoreMeter.instance.meta_score < 1:
		out_of_meta_points.emit()
		return false
	return true

func advance_upgrade(_upgrade_type:Upgrades) -> bool:
	if !check_meta_points(): return false
	
	#print_rich("list = " + Upgrades.keys()[_upgrade_type]+"_levels")
	
	var _level_list : Array = HiveManager.instance.get(Upgrades.keys()[_upgrade_type]+"_levels")
	var _level = _level_list.find(HiveManager.instance.get(Upgrades.keys()[_upgrade_type]))
	
	if _level == -1:
		push_error(DEBUG_NAME,"AdvanceUpgrade > Could not find upgrade '"+Upgrades.keys()[_upgrade_type]+"' :(")
		return false
	elif _level == _level_list.size() - 1:
		if debug: print_rich(DEBUG_NAME,"AdvanceUpgrade > Upgrade at max level! Cancelling.")
		return false
	
	if debug: print_rich(DEBUG_NAME,"AdvanceUpgrade > Success! Upgrading to level " + str(_level + 1))
	HiveManager.instance.set(Upgrades.keys()[_upgrade_type],_level_list[_level + 1])
	
	ScoreMeter.instance.meta_score -= 1
	check_meta_points()
	return true




func advance_upgrade_level(_current_value:Variant,_level_list:Array) -> Variant:
	
	var _level = _level_list.find(_current_value)
		
	if _level == -1:
		push_error(DEBUG_NAME,"AdvanceUpgradeLevel > Could not find value '"+str(_current_value)+"' :(")
		return -1
	elif _level == _level_list.size() - 1:
		if debug: print_rich(DEBUG_NAME,"[color=orange]AdvanceUpgradeLevel > Already at max level! Cancelling.")
		return -1
	
	if debug: print_rich(DEBUG_NAME,"AdvanceUpgradeLevel > Success! Upgrading to level " + str(_level + 1))
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
	if debug: print_rich(DEBUG_NAME,"UpgradeHoleSpeedMultiplier > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_hole_speed_multiplier,HiveManager.upgrade_hole_speed_multiplier_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeHoleSpeedMultiplier > Success! New value = " + str(_new_value))
		HiveManager.upgrade_hole_speed_multiplier = _new_value


func upgrade_hole_output_number() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeHoleOutputNumber > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_hole_output_number,HiveManager.upgrade_hole_output_number_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeHoleOutputNumber > Success! New value = " + str(_new_value))
		HiveManager.upgrade_hole_output_number = _new_value



func upgrade_starting_number_of_nurseries() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfNurseries > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_nurseries,HiveManager.upgrade_starting_number_of_nurseries_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfNurseries > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_nurseries = _new_value

func upgrade_nursery_speed_multiplier() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeNurserySpeedMultiplier > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_nursery_speed_multiplier,HiveManager.upgrade_nursery_speed_multiplier_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeNurserySpeedMultiplier > Success! New value = " + str(_new_value))
		HiveManager.upgrade_nursery_speed_multiplier = _new_value


func upgrade_starting_number_of_jelly_factories() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfJellyFactories > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_jelly_factories,HiveManager.upgrade_starting_number_of_jelly_factories_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfJellyFactories > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_jelly_factories = _new_value

func upgrade_jelly_factory_speed_multiplier() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeJellyFactorySpeedMultiplier > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_jelly_factory_speed_multiplier,HiveManager.upgrade_jelly_factory_speed_multiplier_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeJellyFactorySpeedMultiplier > Success! New value = " + str(_new_value))
		HiveManager.upgrade_jelly_factory_speed_multiplier = _new_value



func upgrade_starting_number_of_kiss_stations() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeNumberOfKissStations > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_kiss_stations,HiveManager.upgrade_starting_number_of_kiss_stations_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeNumberOfKissStations > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_kiss_stations = _new_value


func upgrade_kiss_station_speed_multiplier() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeKissStationSpeedMultiplier > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_kiss_station_speed_multiplier,HiveManager.upgrade_kiss_station_speed_multiplier_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeKissStationSpeedMultiplier > Success! New value = " + str(_new_value))
		HiveManager.upgrade_kiss_station_speed_multiplier = _new_value


func upgrade_kiss_station_chance_to_double_kiss() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeKissStationChanceToDoubleKiss > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_kiss_station_chance_to_double_kiss,HiveManager.upgrade_kiss_station_chance_to_double_kiss_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeKissStationChanceToDoubleKiss > Success! New value = " + str(_new_value))
		HiveManager.upgrade_kiss_station_chance_to_double_kiss = _new_value


func upgrade_kiss_station_cooldown() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeKissStationCooldown > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_kiss_station_cooldown,HiveManager.upgrade_kiss_station_cooldown_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeKissStationCooldown > Success! New value = " + str(_new_value))
		HiveManager.upgrade_kiss_station_cooldown = _new_value



func upgrade_starting_number_of_honeycombs() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfHoneycombs > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_honeycombs,HiveManager.upgrade_starting_number_of_honeycombs_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfHoneycombs > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_honeycombs = _new_value

func upgrade_honeycomb_capacity() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeHoneycombCapacity > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_honeycomb_capacity,HiveManager.upgrade_honeycomb_capacity_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeHoneycombCapacity > Success! New value = " + str(_new_value))
		HiveManager.upgrade_honeycomb_capacity = _new_value




func upgrade_starting_number_of_dancepads() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfDancepads > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_dancepads,HiveManager.upgrade_starting_number_of_dancepads_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfDancepads > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_dancepads = _new_value

func upgrade_dancepad_cooldown() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeDancepadCooldown > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_dancepad_cooldown,HiveManager.upgrade_dancepad_cooldown_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeDancepadCooldown > Success! New value = " + str(_new_value))
		HiveManager.upgrade_dancepad_cooldown = _new_value



func upgrade_construction_speed_multiplier() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeConstructionSpeedMultiplier > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_construction_speed_multiplier,HiveManager.upgrade_construction_speed_multiplier_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeConstructionSpeedMultiplier > Success! New value = " + str(_new_value))
		HiveManager.upgrade_construction_speed_multiplier = _new_value


func upgrade_starting_number_of_impassable_around_royal_chambers() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfImpassableAroundRoyalChambers > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_impassable_around_royal_chambers,HiveManager.upgrade_starting_number_of_impassable_around_royal_chambers_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfImpassableAroundRoyalChambers > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_impassable_around_royal_chambers = _new_value

func upgrade_royal_chambers_order_cooldown() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeRoyalChambersOrderCooldown > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_royal_chambers_order_cooldown,HiveManager.upgrade_royal_chambers_order_cooldown_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeRoyalChambersOrderCooldown > Success! New value = " + str(_new_value))
		HiveManager.upgrade_royal_chambers_order_cooldown = _new_value



#endregion


#region OBJECT UPGRADE FUNCTIONS

func upgrade_starting_number_of_larvae() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfLarvae > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_larvae,HiveManager.upgrade_starting_number_of_larvae_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfLarvae > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_larvae = _new_value



func upgrade_starting_number_of_nectar() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfNectar > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_nectar,HiveManager.upgrade_starting_number_of_nectar_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfNectar > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_nectar = _new_value

func upgrade_starting_number_of_pollen() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfPollen > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_pollen,HiveManager.upgrade_starting_number_of_pollen_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfPollen > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_pollen = _new_value

func upgrade_starting_number_of_royal_jelly() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfRoyalJelly > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_royal_jelly,HiveManager.upgrade_starting_number_of_royal_jelly_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfImpassableAroundRoyalChambers > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_royal_jelly = _new_value

func upgrade_starting_number_of_honey() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfHoney > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_honey,HiveManager.upgrade_starting_number_of_honey_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfHoney > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_honey = _new_value

func upgrade_starting_number_of_workers() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfWorkers > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_starting_number_of_workers,HiveManager.upgrade_starting_number_of_workers_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeStartingNumberOfWorkers > Success! New value = " + str(_new_value))
		HiveManager.upgrade_starting_number_of_workers = _new_value



func upgrade_larvae_amount_of_food_needed() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeLarvaeAmountOfFoodNeeded > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_larvae_amount_of_food_needed,HiveManager.upgrade_larvae_amount_of_food_needed_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeLarvaeAmountOfFoodNeeded > Success! New value = " + str(_new_value))
		HiveManager.upgrade_larvae_amount_of_food_needed = _new_value

func upgrade_larvae_eating_speed_multiplier() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeLarvaeEatingSpeedMultiplier > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_larvae_eating_speed_multiplier,HiveManager.upgrade_larvae_eating_speed_multiplier_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeLarvaeEatingSpeedMultiplier > Success! New value = " + str(_new_value))
		HiveManager.upgrade_larvae_eating_speed_multiplier = _new_value

func upgrade_larvae_move_speed() -> void:
	if debug: print_rich(DEBUG_NAME,"UpgradeLarvaeMoveSpeed > Upgrading...")
	var _new_value = advance_upgrade_level(HiveManager.upgrade_larvae_move_speed,HiveManager.upgrade_larvae_move_speed_levels)
	if _new_value != -1:
		if debug: print_rich(DEBUG_NAME,"UpgradeLarvaeMoveSpeed > Success! New value = " + str(_new_value))
		HiveManager.upgrade_larvae_move_speed = _new_value




#endregion
