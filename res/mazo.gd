extends Node2D
var array_cartas: Array
var clickable = false
var carta_scene: PackedScene = load("res://res/carta.tscn")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func deal(n: int):
	var i = 0
	var aux_array= []
	while i < n:
		aux_array.append(carta_scene.instantiate())
		i+=1
		#pasar a func deal->
	for c in aux_array:
		$"../cartas".add_child(c)
		c.position = position
		c.mano_ref = $"../spaces/mano"
		c.en_espacio = $"../spaces/mano"
		await get_tree().create_timer(0.2).timeout
	$"../spaces/mano".array_cartas.append_array(aux_array)
	$"../spaces/mano".repartir()
	

	
func shuffle():
	var aux_array : Array
	var aux_carta
	var total = array_cartas.size()
	for i in range(total):
		aux_carta = array_cartas.pick_random()
		aux_array.append(aux_carta)
		array_cartas.erase(aux_carta)
	array_cartas.append_array(aux_array)


func _on_mouse_entered() -> void:
	clickable = true


func _on_mouse_exited() -> void:
	clickable = false
