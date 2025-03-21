class_name CartaEspacio extends StaticBody2D
@export var id = 0
var is_empty := true
var carta

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)#semi-transparent when obj not inside


func _process(_delta: float) -> void:
	if get_parent().get_parent().dragging:#TODO- evitar que se muestre cuando el click es corto 
		visible = true
	else:
		visible = false
