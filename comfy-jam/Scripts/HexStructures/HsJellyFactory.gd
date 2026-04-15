class_name HexStructureJellyFactory extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsJellyFactory][/b] "

var texture : Texture = null

var bee_sprite : Sprite2D = null

@export var startup_time : float = 1
@export var wrapup_time : float = 1

@export var production_time : float = 10

@export var speed_multiplier : float = 1


func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(JellyFactory) > Yep!")
	bee_sprite = $HsJellyFactory
	texture = preload("res://Assets/Images/Structures/HS_JellyFactory_Bee.png")
	
	max_workers = 1
	
	



func activate() -> void:
	print_rich(DEBUG_NAME,"Activate > Worker assigned, beginning to produce!")
	bee_sprite.texture = texture
	active = true
	
	super()
	
	producing()

func producing() -> void:
	while (active):
		
		await start_production()
		
		await get_tree().create_timer(production_time * speed_multiplier).timeout
		
		await finish_production()
		
		add_object_to_output()
		output_object()
		
		await on_outputs_empty
		



func start_production() -> void:
	await get_tree().create_timer(startup_time).timeout

func finish_production() -> void:
	await get_tree().create_timer(wrapup_time).timeout
