class_name HexStructureKissStation extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsKissStation][/b] "


var _sprite : AnimatedSprite2D = null


@export var startup_time : float = 1
@export var wrapup_time : float = 3

@export var kissing_time : float = 5


@export_category("READ ONLY")
@export var speed_multiplier : float = 1
@export var kissing_cooldown : float = 15

@export var kissing : bool = false
@export var kissing_cooldowning : bool = false
@export var last_nectar_kiss_level : Nectar.KissLevel = Nectar.KissLevel.UNKISSED

func get_missing_objects() -> Array[ObjectManager.ObjectType]:
	var _missing_objects : Array[ObjectManager.ObjectType] = super()
	if !kissing && !kissing_cooldowning: _missing_objects.append(ObjectManager.ObjectType.NECTAR)
	return _missing_objects

func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(KissStation) > Yep!")
	_sprite = $HsKissStation
	_sprite.play("waiting")
	
	
	speed_multiplier = HiveManager.upgrade_kiss_station_speed_multiplier * HiveManager.upgrade_global_speed_multiplier
	kissing_cooldown = HiveManager.upgrade_kiss_station_cooldown
	
	max_workers = 1


func nectar_dropped_here(_nectar:Nectar) -> bool:
	if !active || kissing || kissing_cooldowning || is_waiting_for_output_removed: return false
	
	print_rich(DEBUG_NAME,"NectarDroppedHere > Using Nectar to start kissing...")
	last_nectar_kiss_level = _nectar.kissed_level
	ObjectManager.move_and_destroy(_nectar,hex.global_position)
	kiss()
	
	return true


func activate() -> void:
	print_rich(DEBUG_NAME,"Activate > Ready to recieve nectar")
	active = true
	
	super()




func kiss() -> void:
	kissing = true
	var _outputted_honey : bool = false
	var _nectar_output : Nectar = null
	update_tooltip_info()
	
	await start_kissing()
	
	await get_tree().create_timer(kissing_time / speed_multiplier).timeout
	
	await finish_kissing()
	
	kissing = false
	
	# Check if nectar is kissed enough
	if last_nectar_kiss_level == Nectar.KissLevel.VERY_KISSED:
		print_rich(DEBUG_NAME,"Kiss > We've kissed the nectar into Honey!")
		_outputted_honey = true
		add_object_to_output(ObjectManager.ObjectType.HONEY)
		output_object()
	
	else:
		add_object_to_output(ObjectManager.ObjectType.NECTAR)
		output_object()
		
		_nectar_output = (output as Nectar)
		_nectar_output.kissed_level = Nectar.KissLevel.values()[(last_nectar_kiss_level as int) + 1]
		print_rich(DEBUG_NAME,"Kiss > Kissed nectar up to " + str(Nectar.KissLevel.values()[_nectar_output.kissed_level]))
	
	
	kissing_cooldowning = true
	update_tooltip_info()
	
	
	#sprite.modulate = Color(1,1,1,0.7)
	await get_tree().create_timer(kissing_cooldown).timeout
	#sprite.modulate = Color(1,1,1,1)
	_sprite.play("waiting")
	kissing_cooldowning = false
	update_tooltip_info()
	
	if !_outputted_honey:
		if is_instance_valid(_nectar_output) && output == _nectar_output:
			print_rich(DEBUG_NAME,"[color=orange] Kiss > Our nectar is still here, trying to kiss again")
			output = null
			is_waiting_for_output_removed = false
			is_waiting_for_output_removed_by_player = false
			last_nectar_kiss_level = _nectar_output.kissed_level
			ObjectManager.move_and_destroy(_nectar_output,hex.global_position)
			kiss()
		else:
			ask_others_to_offer_their_output()


func start_kissing() -> void:
	_sprite.play("kissing")
	await get_tree().create_timer(startup_time).timeout
	

func finish_kissing() -> void:
	_sprite.play("cooldown")
	await get_tree().create_timer(wrapup_time).timeout
