extends CartaEspacio
var array_cartas : Array
# posiciones
var size = Vector2(3185,1012)*scale
var carta_size = Vector2(637,1012)*scale



@onready var mazo = $"../../mazo"
@onready var juego = $"../.."



func _ready():
	modulate = Color(Color.MEDIUM_PURPLE, 0.7)

func div1(n):
	return n if n>0 else 1

func repartir():
	var diff_pos : float = (3185/div1(array_cartas.size()) - 637/div1(array_cartas.size()) + 60)*scale.x
	var i = 1
	var tween = get_tree().create_tween()
	for c in array_cartas:
		var new_pos = position - Vector2(637/array_cartas.size(),0)*scale + Vector2(diff_pos*i,0)
		tween.tween_property(c, "position", new_pos, 0.2).set_ease(Tween.EASE_OUT)
		i+=1
	juego.ordena()
		
	

	
func reordenar(): #igual que repartir pero todos los tweens van a la vez
	var diff_pos : float = (3185/div1(array_cartas.size()) 
							- 637/div1(array_cartas.size()) + 80)*scale.x
	var i = 1
	var tween
	for c in array_cartas:
		#TODO- check error started with no tweeners
		#es por reutilizar el tween, pero si no las animaciones van una por una
		var new_pos = position - Vector2(637/div1(array_cartas.size()),0)*scale + Vector2(diff_pos*i,0)
		tween = get_tree().create_tween()
		tween.tween_property(c, "position", new_pos, position.distance_to(new_pos)/juego.vel).set_ease(Tween.EASE_OUT)
		i+=1



	
