class_name HexStructureKissStation extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsKissStation][/b] "

var texture_1 : Texture = null
var texture_2 : Texture = null

var sprite : Sprite2D = null


@export var startup_time : float = 1
@export var wrapup_time : float = 3

@export var production_time : float = 10

@export var speed_multiplier : float = 1

@export_category("READ ONLY")

@export var kissing : bool = false

func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(KissStation) > Yep!")
	sprite = $HsKissStation
	texture_1 = preload("res://Assets/Images/Structures/HS_KissingBooth_bee.png")
	texture_2 = preload("res://Assets/Images/Structures/HS_KissingBooth_bee_kiss.png")
	
	max_workers = 1


func nectar_dropped_here(_nectar:Nectar) -> bool:
	if !active || kissing: return false
	
	print_rich(DEBUG_NAME,"NectarDroppedHere > Using Nectar to start kissing...")
	ObjectManager.move_and_destroy(_nectar,hex.global_position)
	kiss()
	
	return true


func activate() -> void:
	print_rich(DEBUG_NAME,"ObjectDroppedHere > Worker assigned, beginning to forage!")
	sprite.texture = texture_1
	active = true
	
	super()


func kiss() -> void:
	kissing = true
	
	await start_kissing()
		
	await get_tree().create_timer(production_time * speed_multiplier).timeout
	
	await finish_kissing()
	
	add_object_to_output()
	output_object()
	
	await on_outputs_empty
	
	kissing = false



func start_kissing() -> void:
	sprite.texture = texture_2
	await get_tree().create_timer(startup_time).timeout
	

func finish_kissing() -> void:
	sprite.texture = texture_1
	await get_tree().create_timer(wrapup_time).timeout
