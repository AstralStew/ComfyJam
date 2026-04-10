class_name Tooltip extends Control
const DEBUG_NAME : String = "[b][Tooltip][/b] "

static var instance : Tooltip = null

static var max_width : float = 164

@onready var label : RichTextLabel = $Rtl_Tooltip

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if visible: global_position = get_global_mouse_position()

func _ready() -> void:
	instance = self


static func show_tooltip(_text:String="", _title:String="",_missing:String="") -> void:
	instance.label.text = ""
	#instance.label.size = Vector2(0,0)
	instance.label.reset_size()
	instance.label.text = ("[b]"+_title+"[/b]\n" if _title != "" else "") + _text + ("\n[color=a60050][b]* Missing:[/b] "+_missing if _missing != "" else "")
	
	if instance.label.size.x > max_width:
		instance.label.size.x = max_width
	
	instance.visible = true

static func hide_tooltip() -> void:
	instance.visible = false
