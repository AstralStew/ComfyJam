class_name HexStructureConstruction extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsConstruction][/b] "

var texture_2 : Texture = null

var sprite : Sprite2D = null

var progress_hex : TextureProgressBar  = null


@export var startup_time : float = 1
@export var wrapup_time : float = 3

@export var speed_multiplier : float = 1

@export_category("READ ONLY")

@export var building : bool = false

@export var construction_type : StructureManager.StructureType = StructureManager.StructureType.BLANK

@export var inputs : Array[ObjectManager.ObjectType] = []
@export var build_time : float = -1

func get_missing_objects() -> Array[ObjectManager.ObjectType]:
	var _missing_objects : Array[ObjectManager.ObjectType] = super()
	_missing_objects.append_array(inputs)
	return _missing_objects

func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup > Yep!")
	sprite = $HsConstruction
	progress_hex = $ProgressHex
	texture_2 = preload("res://Assets/Images/Structures/HS_UnderConstruction_Bee.png")
	max_workers = 1

#func adjacent_hex_updated(_hex:Hex) -> bool:
	#print_rich(DEBUG_NAME,"AdjacentHexUpdated > Ignoring adjacent hex '"+_hex.name+"' due to being a Construction and not caring")
	#return false

func set_construction_type(_structure:StructureManager.StructureType) -> bool:
	construction_type = _structure
	
	match _structure:
		StructureManager.StructureType.CONSTRUCTION:
			push_error(DEBUG_NAME,"SetConstructionType -> [color=999966]Structure cannot be CONSTRUCTION! Cancelling")
			return false
		StructureManager.StructureType.BLANK:
			push_error(DEBUG_NAME,"SetConstructionType -> [color=999966]Structure cannot be BLANK! Cancelling")
			return false
		StructureManager.StructureType.HOLE:
			print_rich(DEBUG_NAME,"SetConstructionType -> Construction type = HOLE...")
			inputs = []
			build_time = 15
		StructureManager.StructureType.JELLY_FACTORY:
			print_rich(DEBUG_NAME,"SetConstructionType -> Construction type = JELLY FACTORY...")
			inputs = [
				ObjectManager.ObjectType.NECTAR,
				ObjectManager.ObjectType.POLLEN ]
			build_time = 15
		StructureManager.StructureType.KISS_STATION:
			print_rich(DEBUG_NAME,"SetConstructionType -> Construction type = KISS_STATION...")
			inputs = [
				ObjectManager.ObjectType.POLLEN,
				ObjectManager.ObjectType.NECTAR,
				ObjectManager.ObjectType.NECTAR]
			build_time = 15
		StructureManager.StructureType.NURSERY:
			print_rich(DEBUG_NAME,"SetConstructionType -> Construction type = NURSERY...")
			inputs = [
				ObjectManager.ObjectType.NECTAR,
				ObjectManager.ObjectType.POLLEN,
				ObjectManager.ObjectType.ROYAL_JELLY]
			build_time = 15
		StructureManager.StructureType.HONEYCOMB:
			print_rich(DEBUG_NAME,"SetConstructionType -> Construction type = HONEYCOMB...")
			inputs = [
				ObjectManager.ObjectType.POLLEN, 
				ObjectManager.ObjectType.POLLEN,
				ObjectManager.ObjectType.HONEY]
			build_time = 15
		StructureManager.StructureType.DANCEPAD:
			print_rich(DEBUG_NAME,"SetConstructionType -> Construction type = DANCEPAD...")
			inputs = [
				ObjectManager.ObjectType.HONEY, 
				ObjectManager.ObjectType.NECTAR, 
				ObjectManager.ObjectType.POLLEN,
				ObjectManager.ObjectType.ROYAL_JELLY]
			build_time = 15
	
	check_inputs()
	
	return true

func nectar_dropped_here(_nectar:Nectar) -> bool:
	if !active || building: return false
	
	if !inputs.has(ObjectManager.ObjectType.NECTAR):
		print_rich(DEBUG_NAME,"NectarDroppedHere > Not present in inputs, returning false")
		return false
	
	print_rich(DEBUG_NAME,"NectarDroppedHere > Removing a Nectar from the inputs...")
	ObjectManager.move_and_destroy(_nectar,hex.global_position)
	
	inputs.remove_at(inputs.rfind(ObjectManager.ObjectType.NECTAR))
	check_inputs()
	
	return true

func pollen_dropped_here(_pollen:Pollen) -> bool:
	if !active || building: return false
	
	if !inputs.has(ObjectManager.ObjectType.POLLEN):
		print_rich(DEBUG_NAME,"PollenDroppedHere > Not present in inputs, returning false")
		return false
	
	print_rich(DEBUG_NAME,"PollenDroppedHere > Removing a Pollen from the inputs...")
	ObjectManager.move_and_destroy(_pollen,hex.global_position)
	
	inputs.remove_at(inputs.rfind(ObjectManager.ObjectType.POLLEN))
	check_inputs()
	
	return true

func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	if !active || building: return false
	
	if !inputs.has(ObjectManager.ObjectType.ROYAL_JELLY):
		print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > Not present in inputs, returning false")
		return false
	
	print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > Removing a Royal Jelly from the inputs...")	
	ObjectManager.move_and_destroy(_royal_jelly,hex.global_position)
	
	inputs.remove_at(inputs.rfind(ObjectManager.ObjectType.ROYAL_JELLY))
	check_inputs()
	
	return true

func honey_dropped_here(_honey:Honey) -> bool:
	if !active || building: return false
	
	if !inputs.has(ObjectManager.ObjectType.HONEY):
		print_rich(DEBUG_NAME,"HoneyDroppedHere > Not present in inputs, returning false")
		return false
	
	print_rich(DEBUG_NAME,"HoneyDroppedHere > Removing a Honey from the inputs...")	
	ObjectManager.move_and_destroy(_honey,hex.global_position)
	
	inputs.remove_at(inputs.rfind(ObjectManager.ObjectType.HONEY))
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
	ObjectManager.move_and_destroy(_worker,hex.global_position)
	
	inputs.remove_at(inputs.rfind(ObjectManager.ObjectType.WORKER))
	check_inputs()
	
	return true


func check_inputs() -> void:
	if !active || building: return
	
	update_tooltip_info()
	
	await get_tree().process_frame
	while get_tree().paused:
		await get_tree().process_frame
	if inputs.size() == 0:
		print_rich(DEBUG_NAME,"CheckInputs > No inputs remain! Starting build")
		build()


func activate() -> void:
	print_rich(DEBUG_NAME,"ObjectDroppedHere > Worker assigned, beginning construction!")
	sprite.texture = texture_2
	active = true
	
	super()
	
	check_inputs()


var _tween : Tween = null
func build() -> void:
	building = true
	
	await start_building()
	
	progress_hex.visible = true
	
	if _tween: _tween.kill()
	_tween = create_tween().set_parallel()
	_tween.tween_property(progress_hex,"value",progress_hex.max_value,build_time * speed_multiplier)
	
	await get_tree().create_timer(build_time * speed_multiplier).timeout
	
	await finish_building()
	
	progress_hex.visible = false
	progress_hex.value = 0
	
	hex.structure = null
	StructureManager.set_structure(hex,construction_type)
	
	queue_free()



func start_building() -> void:
	sprite.texture = texture_2
	await get_tree().create_timer(startup_time).timeout
	

func finish_building() -> void:
	#sprite.texture = texture_1
	await get_tree().create_timer(wrapup_time).timeout
