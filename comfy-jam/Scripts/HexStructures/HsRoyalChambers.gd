class_name HexStructureRoyalChambers extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsRoyalChambers][/b] "



@export var startup_time : float = 0.1
@export var wrapup_time : float = 0.1

@export var cooldown_time : float = 25

@export var speed_multiplier : float = 1





@export var order_level : int = 1


@export_category("READ ONLY")

@export var cooling_down : bool = false

@export var order_recipe : Array[ObjectManager.ObjectType] = []

var number_of_orders : float = 0
var order_number : float = 0



func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(RoyalChambers) > Yep!")
	
	number_of_orders = order_level + 3
	

func create_order() -> void:
	
	order_number += 1
	
	if order_number > number_of_orders:
		# cancel and start worker stuff
		print_rich(DEBUG_NAME,"CreateOrder > WE DID IT! Cancelling and starting worker stuff")
		return
	
	print_rich(DEBUG_NAME,"CreateOrder > Time to create a new order!")
	
	for i in order_level:
		order_recipe.append(ObjectManager.ObjectType.values().pick_random())
	
	order_level += 1
	






func check_order() -> void:
	if !active || cooling_down: return
	
	await get_tree().process_frame
	while get_tree().paused:
		await get_tree().process_frame
	if order_recipe.size() == 0:
		print_rich(DEBUG_NAME,"Checkorder > No order remain! Completing order")
		complete_order()


func activate() -> void:
	print_rich(DEBUG_NAME,"Activate > Time to take and give some orders!")
	#sprite.texture = texture_2
	active = true
	
	super()
	
	cooldown()


func complete_order() -> void:
	print_rich(DEBUG_NAME,"CompleteOrder > Order has been completed!")
	cooldown()

func cooldown() -> void:
	
	print_rich(DEBUG_NAME,"Cooldown > Time to cool off..")
	
	cooling_down = true
	
	await start_cooling_down()
		
	await get_tree().create_timer(cooldown_time * speed_multiplier).timeout
	
	await finish_cooling_down()
	
	
	cooling_down = false
	
	print_rich(DEBUG_NAME,"Cooldown > Alright, cooled off. Let's do this.")
	
	create_order()
	



func start_cooling_down() -> void:
	#sprite.texture = texture_2
	await get_tree().create_timer(startup_time).timeout
	

func finish_cooling_down() -> void:
	#sprite.texture = texture_1
	await get_tree().create_timer(wrapup_time).timeout








func nectar_dropped_here(_nectar:Nectar) -> bool:
	if !active || cooling_down: return false
	
	if !order_recipe.has(ObjectManager.ObjectType.NECTAR):
		print_rich(DEBUG_NAME,"NectarDroppedHere > Not present in order, returning false")
		return false
	
	print_rich(DEBUG_NAME,"NectarDroppedHere > Removing a Nectar from the order...")
	ObjectManager.move_and_destroy(_nectar,hex.global_position)
	
	order_recipe.remove_at(order_recipe.rfind(ObjectManager.ObjectType.NECTAR))
	check_order()
	
	return true

func pollen_dropped_here(_pollen:Pollen) -> bool:
	if !active || cooling_down: return false
	
	if !order_recipe.has(ObjectManager.ObjectType.POLLEN):
		print_rich(DEBUG_NAME,"PollenDroppedHere > Not present in order, returning false")
		return false
	
	print_rich(DEBUG_NAME,"PollenDroppedHere > Removing a Pollen from the order...")
	ObjectManager.move_and_destroy(_pollen,hex.global_position)
	
	order_recipe.remove_at(order_recipe.rfind(ObjectManager.ObjectType.POLLEN))
	check_order()
	
	return true

func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	if !active || cooling_down: return false
	
	if !order_recipe.has(ObjectManager.ObjectType.ROYAL_JELLY):
		print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > Not present in order, returning false")
		return false
	
	print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > Removing a Royal Jelly from the order...")	
	ObjectManager.move_and_destroy(_royal_jelly,hex.global_position)
	
	order_recipe.remove_at(order_recipe.rfind(ObjectManager.ObjectType.ROYAL_JELLY))
	check_order()
	
	return true

func worker_dropped_here(_worker:WorkerBee) -> bool:
	if !active || cooling_down: return false
	
	if !order_recipe.has(ObjectManager.ObjectType.WORKER):
		print_rich(DEBUG_NAME,"WorkerDroppedHere > Not present in order, returning false")
		return false
	
	print_rich(DEBUG_NAME,"WorkerDroppedHere > Removing a Worker from the order...")	
	ObjectManager.move_and_destroy(_worker,hex.global_position)
	
	order_recipe.remove_at(order_recipe.rfind(ObjectManager.ObjectType.WORKER))
	check_order()
	
	return true


func larvae_dropped_here(_larvae:Larvae) -> bool:
	if !active || cooling_down: return false
	
	if !order_recipe.has(ObjectManager.ObjectType.LARVAE):
		print_rich(DEBUG_NAME,"LarvaeDroppedHere > Not present in order, returning false")
		return false
	
	print_rich(DEBUG_NAME,"LarvaeDroppedHere > Removing a Worker from the order...")	
	ObjectManager.move_and_destroy(_larvae,hex.global_position)
	
	order_recipe.remove_at(order_recipe.rfind(ObjectManager.ObjectType.LARVAE))
	check_order()
	
	return true
