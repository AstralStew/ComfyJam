extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	play()


func play() -> void:
	while (true):
		
		var _tween = create_tween().set_parallel(true)
		_tween.tween_property(self, "scale", Vector2(0.1,0.1), 1)
		_tween.tween_property(self, "modulate", Color(0,0,0,0), 1)
		await _tween.finished
		
		await get_tree().create_timer(5 + (randi() % 5)).timeout
		
		_tween = create_tween().set_parallel(true)
		_tween.tween_property(self, "scale", Vector2(0.445,0.445), 3)
		_tween.tween_property(self, "modulate", Color.WHITE, 3)
		await _tween.finished
		
		await get_tree().create_timer(3).timeout
		
