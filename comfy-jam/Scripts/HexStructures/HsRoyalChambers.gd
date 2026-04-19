class_name HexStructureRoyalChambers extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsRoyalChambers][/b] "



@export var startup_time : float = 0.1
@export var wrapup_time : float = 0.1


@export var speed_multiplier : float = 1


var game_time_hex : TextureProgressBar  = null



@export var order_level : int = 1


@export_category("READ ONLY")

@export var countdown_time : float = -1

@export var countdowning : bool = false

#@export var order_recipe : Array[ObjectManager.ObjectType] = []

func get_missing_objects() -> Array[ObjectManager.ObjectType]:
	#if !cooling_down: return order_recipe
	if countdowning:
		return [ObjectManager.ObjectType.HONEY]
	else: return []

#var number_of_orders : float = 0
#var order_number : float = 0



func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(RoyalChambers) > Yep!")
	
	game_time_hex = $GameTimeHex
	
	countdown_time = HiveManager.upgrade_royal_chambers_order_cooldown
	#speed_multiplier = HiveManager.upgrade_global_speed_multiplier
	
	#number_of_orders = order_level + 3
	
#
#func create_order() -> void:
	#
	#order_number += 1
	#
	#if order_number > number_of_orders:
		## cancel and start worker stuff
		#print_rich(DEBUG_NAME,"CreateOrder > WE DID IT! Cancelling and starting worker stuff")
		#return
	#
	#print_rich(DEBUG_NAME,"CreateOrder > Time to create a new order!")
	#
	#for i in order_level:
		#order_recipe.append(ObjectManager.ObjectType.values().pick_random())
	#
	#order_level += 1
	#
#
#func _process(delta: float) -> void:
	#
	#game_time_hex.value = (HiveManager.game_time / HiveManager.game_length) * game_time_hex.max_value


#
#
#func check_order() -> void:
	#if !active || cooling_down: return
	#
	#update_tooltip_info()
	#
	#await get_tree().process_frame
	#while get_tree().paused:
		#await get_tree().process_frame
	#if order_recipe.size() == 0:
		#print_rich(DEBUG_NAME,"Checkorder > No order remain! Completing order")
		#complete_order()
	#


func activate() -> void:
	print_rich(DEBUG_NAME,"Activate > Time to collect honey!")
	#sprite.texture = texture_2
	active = true
	
	super()
	
	#countdown()


#func complete_order() -> void:
	#print_rich(DEBUG_NAME,"CompleteOrder > Order has been completed!")
	#ScoreMeter.royal_order_complete()
	#cooldown()


var _tween : Tween = null
func countdown() -> void:
	
	print_rich(DEBUG_NAME,"Countdown > Time to cool off..")
	
	countdowning = true
	
	await start_countdown()
	
	game_time_hex.value = 0
	game_time_hex.visible = true
	
	if _tween: _tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(game_time_hex,"value",game_time_hex.max_value,countdown_time)
	
	await get_tree().create_timer(countdown_time+1).timeout
	
	
	await finish_countdown()
	
	
	countdowning = false
	
	print_rich(DEBUG_NAME,"Countdown > Alright, cooled off. Let's do this.")
	
	HiveManager.instance._on_hive_finish.emit()
	



func start_countdown() -> void:
	#sprite.texture = texture_2
	await get_tree().create_timer(startup_time).timeout
	

func finish_countdown() -> void:
	#sprite.texture = texture_1
	await get_tree().create_timer(wrapup_time).timeout







#
#func nectar_dropped_here(_nectar:Nectar) -> bool:
	#if !active || cooling_down: return false
	#
	#if !order_recipe.has(ObjectManager.ObjectType.NECTAR):
		#print_rich(DEBUG_NAME,"NectarDroppedHere > Not present in order, returning false")
		#return false
	#
	#print_rich(DEBUG_NAME,"NectarDroppedHere > Removing a Nectar from the order...")
	#ObjectManager.move_and_destroy(_nectar,hex.global_position)
	#
	#order_recipe.remove_at(order_recipe.rfind(ObjectManager.ObjectType.NECTAR))
	#check_order()
	#
	#return true
#
#func pollen_dropped_here(_pollen:Pollen) -> bool:
	#if !active || cooling_down: return false
	#
	#if !order_recipe.has(ObjectManager.ObjectType.POLLEN):
		#print_rich(DEBUG_NAME,"PollenDroppedHere > Not present in order, returning false")
		#return false
	#
	#print_rich(DEBUG_NAME,"PollenDroppedHere > Removing a Pollen from the order...")
	#ObjectManager.move_and_destroy(_pollen,hex.global_position)
	#
	#order_recipe.remove_at(order_recipe.rfind(ObjectManager.ObjectType.POLLEN))
	#check_order()
	#
	#return true
#
#func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	#if !active || cooling_down: return false
	#
	#if !order_recipe.has(ObjectManager.ObjectType.ROYAL_JELLY):
		#print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > Not present in order, returning false")
		#return false
	#
	#print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > Removing a Royal Jelly from the order...")	
	#ObjectManager.move_and_destroy(_royal_jelly,hex.global_position)
	#
	#order_recipe.remove_at(order_recipe.rfind(ObjectManager.ObjectType.ROYAL_JELLY))
	#check_order()
	#
	#return true
#
#func worker_dropped_here(_worker:WorkerBee) -> bool:
	#if !active || cooling_down: return false
	#
	#if !order_recipe.has(ObjectManager.ObjectType.WORKER):
		#print_rich(DEBUG_NAME,"WorkerDroppedHere > Not present in order, returning false")
		#return false
	#
	#print_rich(DEBUG_NAME,"WorkerDroppedHere > Removing a Worker from the order...")	
	#ObjectManager.move_and_destroy(_worker,hex.global_position)
	#
	#order_recipe.remove_at(order_recipe.rfind(ObjectManager.ObjectType.WORKER))
	#check_order()
	#
	#return true
#
#
#func larvae_dropped_here(_larvae:Larvae) -> bool:
	#if !active || cooling_down: return false
	#
	#if !order_recipe.has(ObjectManager.ObjectType.LARVAE):
		#print_rich(DEBUG_NAME,"LarvaeDroppedHere > Not present in order, returning false")
		#return false
	#
	#print_rich(DEBUG_NAME,"LarvaeDroppedHere > Removing a Worker from the order...")	
	#ObjectManager.move_and_destroy(_larvae,hex.global_position)
	#
	#order_recipe.remove_at(order_recipe.rfind(ObjectManager.ObjectType.LARVAE))
	#check_order()
	#
	#return true


func honey_dropped_here(_honey:Honey) -> bool:
	if !active: return false
	
	if !countdowning: 
		countdown()
		
	
	#if !order_recipe.has(ObjectManager.ObjectType.HONEY):
		#print_rich(DEBUG_NAME,"HoneyDroppedHere > Not present in order, returning false")
		#return false
	
	print_rich(DEBUG_NAME,"HoneyDroppedHere > Removing a Honey from the order...")	
	ObjectManager.move_and_destroy(_honey,hex.global_position)
	
	ScoreMeter.honey_scored()
	
	
	#order_recipe.remove_at(order_recipe.rfind(ObjectManager.ObjectType.HONEY))
	#check_order()
	
	
	return true
