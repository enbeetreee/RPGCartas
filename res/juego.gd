extends Node2D
var card_size = Vector2(0.22, 0.22)
var dragging = false
var observing = false
var vel = 2500
var palos = ["red.png","blue.png","yell.png"]
var puntos = [1,2,3,4]

var victoria = 15
var max_rondas
var ronda_actual = 0

var total_ronda
var total_actual


var max_mano = 9
var deal = 7

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$total.text = str(victoria)
	total_actual = victoria
	total_ronda = victoria
	await get_tree().create_timer(0.5).timeout
	$mazo.deal(deal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass


func _on_calc_button_button_up() -> void:
	comprueba()
	total_ronda = total_actual
	var tween = get_tree().create_tween()
	for space in $spaces.get_children():
		if space.carta and !space.is_in_group("mano"):
			tween.tween_property(space.carta, "position", $descartes.position, space.carta.position.distance_to($descartes.position)/vel).set_ease(Tween.EASE_OUT)
	await tween.finished
	for space in $spaces.get_children():
		if space.carta and !space.is_in_group("mano"):
			space.carta.queue_free()
			space.carta = null
			space.is_empty = true
	
	ronda_actual -=1
	
	if total_ronda<=0: #OH GUAU VITORIA
		#TODO: POP-UP VITORIA
		pass
	elif ronda_actual == max_rondas: #OH NAY PERDISTE
		#TODO: POP-UP PERDISTE
		pass 
	else:
		if $spaces/mano.array_cartas.size()+ deal > max_mano:
			$mazo.deal(max_mano - $spaces/mano.array_cartas.size())
		else:
			$mazo.deal(deal)
	


func comprueba():
	var sum = 0
	var cartas = []

	for space in $spaces.get_children():
		if !space.is_in_group("mano"):
			cartas.push_back(space.carta)

	#puntuacion base + bonos de colores y mismo número
	for i in cartas.size(): 
		if cartas[i]:
			sum+=cartas[i].num
			if i < cartas.size()-1:
				if cartas[i+1]: 
					if cartas[i].palo == cartas[i+1].palo:#color
						sum+=2
					if cartas[i].num == cartas[i+1].num:#num
						sum+=2
						
			if cartas[i-1] and cartas[i-2]:#escalera
				if cartas[i].num == cartas[i-1].num+1 and cartas[i].num == cartas[i-2].num+2:#escalera positiva
					if cartas[i-3]:
						if cartas[i].num== cartas[i-3].num+3:
							sum+=1
						else:
							sum +=3
					else:
						sum +=3
				elif cartas[i].num == cartas[i-1].num-1 and cartas[i].num == cartas[i-2].num-2:#escalera negativa
					if cartas[i-3]:
						if cartas[i].num== cartas[i-3].num-3:
							sum+=1
						else:
							sum +=3
					else:
						sum +=3

	
	total_actual = total_ronda -sum 
	
	$total.text= str(total_actual)#TODO: flashy por extra superado || 0 if total_actual<0 else total_actual
	
func ordena():
	var i = $spaces/mano.array_cartas.size()-1
	for c in $spaces/mano.array_cartas:
		$cartas.move_child(c, i)
		i-=1
