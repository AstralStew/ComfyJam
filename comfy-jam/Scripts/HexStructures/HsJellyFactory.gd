class_name HexStructureJellyFactory extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsJellyFactory][/b] "

var texture : Texture = null

var progress_hex : TextureProgressBar  = null

var bee_sprite : Sprite2D = null

@export var startup_time : float = 1
@export var wrapup_time : float = 1

@export var production_time : float = 10

@export var speed_multiplier : float = 1

@export_category("READ ONLY")

@export var producing : bool = false

@export var items_inputted : float = 0

func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(JellyFactory) > Yep!")
	bee_sprite = $HsJellyFactory
	progress_hex = $ProgressHex
	texture = preload("res://Assets/Images/Structures/HS_JellyFactory_Bee.png")
	
	
	max_workers = 1
	


func pollen_dropped_here(_pollen:Pollen) -> bool:
	if !active || producing || is_waiting_for_output_removed: return false
	
	print_rich(DEBUG_NAME,"PollenDroppedHere > Using Pollen to start producing...")
	ObjectManager.move_and_destroy(_pollen,hex.global_position)
	items_inputted += 1
	
	if items_inputted >= 2:
		produce()
		items_inputted = 0
	
	return true


func activate() -> void:
	print_rich(DEBUG_NAME,"Activate > Worker assigned, beginning to produce!")
	bee_sprite.texture = texture
	active = true
	
	super()
	
	

var _tween : Tween = null
func produce() -> void:
	
	producing = true
	
	await start_production()
	
	if _tween: _tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(progress_hex,"value",12,production_time * speed_multiplier)
	
	await get_tree().create_timer(production_time * speed_multiplier).timeout
	
	await finish_production()
	
	progress_hex.value = 0
	
	producing = false
	
	add_object_to_output()
	output_object()
	
		



func start_production() -> void:
	await get_tree().create_timer(startup_time).timeout

func finish_production() -> void:
	await get_tree().create_timer(wrapup_time).timeout
