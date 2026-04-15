class_name HexStructureNursery extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsNursery][/b] "

var texture_1 : Texture = null
var texture_2 : Texture = null

var sprite : Sprite2D = null


@export var startup_time : float = 1
@export var wrapup_time : float = 3

@export var nurturing_time : float = 30

@export var speed_multiplier : float = 1

@export_category("READ ONLY")

@export var nurturing : bool = false

func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(Nursery) > Yep!")
	sprite = $HsNursery
	texture_1 = preload("res://Assets/Images/Structures/HS_Hatchery_Egg_Bee.png")
	texture_2 = preload("res://Assets/Images/Structures/HS_Hatchery_Larva_Bee.png")
	
	max_workers = 1


func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	if !active || nurturing || is_waiting_for_output_removed: return false
	
	print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > Using Royal Jelly to start nurturing...")
	ObjectManager.move_and_destroy(_royal_jelly,hex.global_position)
	produce()
	
	return true


func activate() -> void:
	print_rich(DEBUG_NAME,"Activate > Ready to recieve royal jelly")
	sprite.texture = texture_1
	active = true
	
	super()


func produce() -> void:
	nurturing = true
	
	await start_nurturing()
		
	await get_tree().create_timer(nurturing_time * speed_multiplier).timeout
	
	await finish_nurturing()
	
	nurturing = false
	
	add_object_to_output()
	output_object()
	



func start_nurturing() -> void:
	sprite.texture = texture_2
	await get_tree().create_timer(startup_time).timeout
	

func finish_nurturing() -> void:
	sprite.texture = texture_1
	await get_tree().create_timer(wrapup_time).timeout
