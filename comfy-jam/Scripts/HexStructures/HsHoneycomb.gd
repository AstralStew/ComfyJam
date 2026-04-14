class_name HexStructureHoneycomb extends HexStructure
func _debug_name() -> String:
	return "[b][" + get_parent().name + "/HsHoneycomb][/b] "

var texture : Texture = null

var honeycomb_sprite : Sprite2D = null

@export var cooldown_time : float = 1

@export var speed_multiplier : float = 1

@export var capacity : int = 4

@export var direction_tl : bool = false
@export var direction_tr : bool = false
@export var direction_l : bool = false
@export var direction_r : bool = false
@export var direction_bl : bool = false
@export var direction_br : bool = false

@export_category("READ ONLY")
@export var is_full : bool = false :
	get: return _outputs.size() + (1 if output != null else 0) >= capacity

var cooldowning : bool = false

func _setup() -> void:
	super()
	
	print_rich(DEBUG_NAME,"Setup(Honeycomb) > Yep")
	honeycomb_sprite = $HsHoneycomb
	texture = preload("res://Assets/Images/Structures/HS_Honeycomb.png")
	
	max_workers = 1
	
	#on_output_object_removed.connect(check_adjacent_hexes)
	on_outputs_added.connect(dispense)


func nectar_dropped_here(_nectar:Nectar) -> bool:
	if !active || is_full:
		return false
	
	#_nectar.queue_free()
	ObjectManager.move_and_destroy(_nectar,hex.global_position)
	add_object_to_output(ObjectManager.ObjectType.NECTAR)
	
	return true

func pollen_dropped_here(_pollen:Pollen) -> bool:
	if !active || is_full:
		return false
	
	#_pollen.queue_free()	
	ObjectManager.move_and_destroy(_pollen,hex.global_position)
	add_object_to_output(ObjectManager.ObjectType.POLLEN)
	
	return true

func royal_jelly_dropped_here(_royal_jelly:RoyalJelly) -> bool:
	if !active || is_full:
		print_rich(DEBUG_NAME,"RoyalJellyDroppedHere > No space for RoyalJelly! Returning false")
		return false
	
	#_royal_jelly.queue_free()
	ObjectManager.move_and_destroy(_royal_jelly,hex.global_position)
	add_object_to_output(ObjectManager.ObjectType.ROYAL_JELLY)
	
	return true


func activate() -> void:
	print_rich(DEBUG_NAME,"Activate > Worker assigned, beginning to produce!")
	honeycomb_sprite.texture = texture
	active = true
	
	#dispensing()

func dispense() -> void:
	await get_tree().create_timer(cooldown_time).timeout
	output_object()

#func dispensing() -> void:
	#while (active):
		
		
		
		#print_rich(DEBUG_NAME,"Dispensing > Waiting for an output to be added...")
		
		#var _result = await on_outputs_added_or_empty()
		#if _result[0] == on_outputs_added && output == null:
				#if (output_on_cooldown):
					#continue
				#await get_tree().create_timer(adjacent_output_removal_delay).timeout
				#output_object()
		#elif _result[0] == on_outputs_empty:
			#await on_outputs_added
			#print_rich(DEBUG_NAME,"Dispensing > Outputting object!")
			#if output == null:
				#output_object()
		
		
		
		
	


func on_outputs_added_or_empty() -> Signal:
	
	var worker = RefCounted.new()
	worker.add_user_signal("result")
		
	for _signal in [on_outputs_added,on_outputs_empty]:
		_signal.connect(
			func(...params):
				worker.emit_signal("result",_signal,params),
				CONNECT_ONE_SHOT
		)
	
	return Signal(worker, "result")
