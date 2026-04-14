class_name HexStructureConstruction extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsConstruction][/b] "

var texture_1 : Texture = null
var texture_2 : Texture = null

var sprite : Sprite2D = null


@export var startup_time : float = 1
@export var wrapup_time : float = 3

@export var speed_multiplier : float = 1

@export_category("READ ONLY")

@export var building : bool = false

@export var construction_type : StructureManager.StructureType = StructureManager.StructureType.BLANK

@export var inputs : Array[ObjectManager.ObjectType] = []
@export var build_time : float = -1

func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup > Yep!")
	sprite = $HsConstruction
	texture_1 = preload("res://Assets/Images/Structures/HS_Hatchery_Egg_Bee.png")
	texture_2 = preload("res://Assets/Images/Structures/HS_Hatchery_Larva_Bee.png")
	max_workers = 1

func adjacent_hex_updated(_hex:Hex) -> bool:
	print_rich(DEBUG_NAME,"AdjacentHexUpdated > Ignoring adjacent hex '"+_hex.name+"' due to being a Construction and not caring")
	return false

func set_construction_type(_structure:StructureManager.StructureType) -> bool:
	construction_type = _structure
	
	match _structure:
		StructureManager.StructureType.CONSTRUCTION:
			print_rich(DEBUG_NAME,"SetConstructionType -> [color=999966]Structure cannot be CONSTRUCTION! Cancelling")
			return false
		StructureManager.StructureType.BLANK:
			print_rich(DEBUG_NAME,"SetConstructionType -> Construction type = BLANK...")
			inputs = []
			build_time = 1
		StructureManager.StructureType.HOLE:
			print_rich(DEBUG_NAME,"SetConstructionType -> Construction type = HOLE...")
			inputs = []
			build_time = 1
		StructureManager.StructureType.JELLY_FACTORY:
			print_rich(DEBUG_NAME,"SetConstructionType -> Construction type = JELLY FACTORY...")
			inputs = [
				ObjectManager.ObjectType.NECTAR,
				ObjectManager.ObjectType.POLLEN ]
			build_time = 4
		StructureManager.StructureType.NURSERY:
			print_rich(DEBUG_NAME,"SetConstructionType -> Construction type = NURSERY...")
			inputs = [
				ObjectManager.ObjectType.NECTAR,
				ObjectManager.ObjectType.NECTAR,
				ObjectManager.ObjectType.POLLEN, 
				ObjectManager.ObjectType.POLLEN]
			build_time = 2
		StructureManager.StructureType.HONEYCOMB:
			print_rich(DEBUG_NAME,"SetConstructionType -> Construction type = HONEYCOMB...")
			inputs = [
				ObjectManager.ObjectType.ROYAL_JELLY,
				ObjectManager.ObjectType.ROYAL_JELLY,
				ObjectManager.ObjectType.NECTAR, 
				ObjectManager.ObjectType.POLLEN]
			build_time = 2
			check_inputs()
	
	return true

func nectar_dropped_here(_nectar:Nectar) -> bool:
	if !active || building: return false
	
	if !inputs.has(ObjectManager.ObjectType.NECTAR):
		print_rich(DEBUG_NAME,"NectarDroppedHere > Not present in inputs, returning false")
		return false
	
	print_rich(DEBUG_NAME,"NectarDroppedHere > Removing a Nectar from the inputs...")
	_nectar.queue_free()
	
	inputs.remove_at(inputs.rfind(ObjectManager.ObjectType.NECTAR))
	check_inputs()
	
	return true

func pollen_dropped_here(_pollen:Pollen) -> bool:
	if !active || building: return false
	
	if !inputs.has(ObjectManager.ObjectType.POLLEN):
		print_rich(DEBUG_NAME,"PollenDroppedHere > Not present in inputs, returning false")
		return false
	
	print_rich(DEBUG_NAME,"PollenDroppedHere > Removing a Pollen from the inputs...")
	_pollen.queue_free()
	
	inputs.remove_at(inputs.rfind(ObjectManager.ObjectType.POLLEN))
	check_inputs()
	
	return true

func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	if !active || building: return false
	
	if !inputs.has(ObjectManager.ObjectType.ROYAL_JELLY):
		print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > Not present in inputs, returning false")
		return false
	
	print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > Removing a Royal Jelly from the inputs...")
	_royal_jelly.queue_free()
	
	inputs.remove_at(inputs.rfind(ObjectManager.ObjectType.ROYAL_JELLY))
	check_inputs()
	
	return true

func worker_dropped_here(_worker:WorkerBee) -> bool:
	if super(_worker):
		return true
	
	if !active || building: return false
	
	if !inputs.has(ObjectManager.ObjectType.WORKER):
		print_rich(DEBUG_NAME,"WorkerDroppedHere > Not present in inputs, returning false")
		return false
	
	print_rich(DEBUG_NAME,"WorkerDroppedHere > Removing a Worker from the inputs...")
	_worker.queue_free()
	
	inputs.remove_at(inputs.rfind(ObjectManager.ObjectType.WORKER))
	check_inputs()
	
	return true


func check_inputs() -> void:
	await get_tree().process_frame
	if inputs.size() == 0:
		print_rich(DEBUG_NAME,"CheckInputs > No inputs remain! Starting build")
		build()


func activate() -> void:
	print_rich(DEBUG_NAME,"ObjectDroppedHere > Worker assigned, beginning construction!")
	sprite.texture = texture_1
	active = true
	
	check_inputs()


func build() -> void:
	building = true
	
	await start_building()
		
	await get_tree().create_timer(build_time * speed_multiplier).timeout
	
	await finish_building()
	
	hex.structure = null
	StructureManager.set_structure(hex,construction_type)
	
	queue_free()



func start_building() -> void:
	sprite.texture = texture_2
	await get_tree().create_timer(startup_time).timeout
	

func finish_building() -> void:
	sprite.texture = texture_1
	await get_tree().create_timer(wrapup_time).timeout
