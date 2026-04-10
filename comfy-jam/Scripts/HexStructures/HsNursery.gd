class_name HexStructureNursery extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsNursery][/b] "

var bee_sprite : Sprite2D = null


@export var startup_time : float = 1
@export var wrapup_time : float = 3

@export var production_time : float = 10

@export var speed_multiplier : float = 1

@export_category("READ ONLY")

@export var producing : bool = false

func _setup() -> void:
	print_rich(DEBUG_NAME,"Setup > Yep!")
	bee_sprite = $Node2D/BeeSprite
	
	max_workers = 1
	

func worker_dropped_here(_worker:WorkerBee) -> bool:
	if !super(_worker):
		# Worker was not used by base class, cancelling here
		return false
	
	# Activate nursery
	if !active && assigned_workers == 1:
		print_rich(DEBUG_NAME,"ObjectDroppedHere > Worker assigned, beginning to forage!")
		bee_sprite.visible = true
		active = true
	
	return true

func nectar_dropped_here(_nectar:Nectar) -> bool:
	if !active || producing: return false
	
	print_rich(DEBUG_NAME,"NectarDroppedHere > Using Nectar to start production...")
	_nectar.queue_free()
	produce()
	
	return true



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
	$Node2D.modulate = Color.GREEN
	await get_tree().create_timer(startup_time).timeout
	

func finish_production() -> void:
	$Node2D.modulate = Color.WHITE
	await get_tree().create_timer(wrapup_time).timeout
