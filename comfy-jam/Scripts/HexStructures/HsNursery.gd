class_name HexStructureNursery extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsNursery][/b] "

var texture_1 : Texture = null
var texture_2 : Texture = null

var _sprite : AnimatedSprite2D = null

var progress_hex : TextureProgressBar  = null

@export var startup_time : float = 1
@export var wrapup_time : float = 3

@export var nurturing_time : float = 30


@export_category("READ ONLY")

@export var speed_multiplier : float = 1

@export var nurturing : bool = false

func get_missing_objects() -> Array[ObjectManager.ObjectType]:
	var _missing_objects : Array[ObjectManager.ObjectType] = super()
	if !nurturing: _missing_objects.append(ObjectManager.ObjectType.ROYAL_JELLY)
	return _missing_objects

func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(Nursery) > Yep!")
	_sprite = $HsNursery
	_sprite.play("default")
	on_outputs_empty.connect(return_to_default_animation)
	progress_hex = $ProgressHex
	texture_1 = preload("res://Assets/Images/Structures/HS_Hatchery_Egg_Bee.png")
	texture_2 = preload("res://Assets/Images/Structures/HS_Hatchery_Larva_Bee.png")
	
	
	speed_multiplier = HiveManager.upgrade_nursery_speed_multiplier * HiveManager.upgrade_global_speed_multiplier
	
	max_workers = 1


func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	if !active || nurturing || is_waiting_for_output_removed: return false
	
	print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > Using Royal Jelly to start nurturing...")
	ObjectManager.move_and_destroy(_royal_jelly,hex.global_position)
	nurture()
	
	return true


func activate() -> void:
	print_rich(DEBUG_NAME,"Activate > Ready to recieve royal jelly")
	active = true
	
	super()


var _tween : Tween = null
func nurture() -> void:
	nurturing = true
	
	await start_nurturing()
		
	progress_hex.value = 0
	progress_hex.visible = true
	
	if _tween: _tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(progress_hex,"value",progress_hex.max_value,nurturing_time / speed_multiplier)
	
	await get_tree().create_timer(nurturing_time / speed_multiplier).timeout
	
	await finish_nurturing()
	
	progress_hex.visible = false
	progress_hex.value = 0
	
	nurturing = false
	
	add_object_to_output()
	output_object()
	

func return_to_default_animation() -> void:
	_sprite.play("default")


func start_nurturing() -> void:
	_sprite.play("nurturing")
	await get_tree().create_timer(startup_time).timeout
	

func finish_nurturing() -> void:
	_sprite.play("nurture_end")
	await get_tree().create_timer(wrapup_time).timeout
