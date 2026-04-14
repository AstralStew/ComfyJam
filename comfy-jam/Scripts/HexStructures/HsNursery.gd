class_name HexStructureNursery extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsNursery][/b] "

var texture_1 : Texture = null
var texture_2 : Texture = null

var sprite : Sprite2D = null


@export var startup_time : float = 1
@export var wrapup_time : float = 3

@export var production_time : float = 10

@export var speed_multiplier : float = 1

@export_category("READ ONLY")

@export var producing : bool = false

func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(Nursery) > Yep!")
	sprite = $HsNursery
	texture_1 = preload("res://Assets/Images/Structures/HS_Hatchery_Egg_Bee.png")
	texture_2 = preload("res://Assets/Images/Structures/HS_Hatchery_Larva_Bee.png")
	
	max_workers = 1


func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	if !active || producing: return false
	
	print_rich(DEBUG_NAME,"NectarDroppedHere > Using Royal Jelly to start production...")
	_royal_jelly.queue_free()
	produce()
	
	return true


func activate() -> void:
	print_rich(DEBUG_NAME,"ObjectDroppedHere > Worker assigned, beginning to forage!")
	sprite.texture = texture_1
	active = true
	
	super()


func produce() -> void:
	producing = true
	
	await start_production()
		
	await get_tree().create_timer(production_time * speed_multiplier).timeout
	
	await finish_production()
	
	add_object_to_output()
	output_object()
	
	await on_outputs_empty
	
	producing = false



func start_production() -> void:
	sprite.texture = texture_2
	await get_tree().create_timer(startup_time).timeout
	

func finish_production() -> void:
	sprite.texture = texture_1
	await get_tree().create_timer(wrapup_time).timeout
