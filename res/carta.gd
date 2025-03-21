#TODO recolocar cartas en indice z
class_name Carta extends Node2D

var mano_ref
@onready var juego = $"../.."

const palos = ["red","blue","yell"]
const puntos = [1,2,3,4]
var num
var palo

#drag&drop
var en_espacio
var heldFrameCount : int = 0
var mouse_offset = Vector2(0,0)# diff entre posición del ratón y posición propia
var dragable = false

var array_drops: Array #array de areas donde puede caer la carta


# MÉTODOS
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	var img = get_child(0)
	var label = get_child(1)
	
	num = puntos.pick_random()
	palo = palos.pick_random()
	img.texture = load("res://img/"+palo+".png")
	label.text = str(num)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if dragable:
		var aux = check_closest()
		if aux: #solo espacio más cercano cambia de color 
			aux.modulate = Color(Color.REBECCA_PURPLE, 0.7)
		for e in array_drops:
			if e!=aux:
				e.modulate = Color(Color.MEDIUM_PURPLE, 0.7)

		drag()


#drag&drop
func drag():
	if Input.is_action_just_pressed("click"):
		heldFrameCount = 0
		mouse_offset = get_global_mouse_position() - global_position
		
	if Input.is_action_just_pressed("r_click"):
		heldFrameCount = -1
		
	if Input.is_action_pressed("click"):
		heldFrameCount += 1
		juego.dragging = true
		global_position = get_global_mouse_position() - mouse_offset
		
	if Input.is_action_just_released("click") or Input.is_action_just_released("r_click"):
		drop()


func drop():
	var drop_ref #area en la que caer
	var tween = get_tree().create_tween()
	juego.dragging = false
	
	
	var init_drop = en_espacio
	var en_mano = init_drop.is_in_group("mano")
	
	#asignación de espacios:
	if heldFrameCount == -1 and !en_mano: #rclick, vuelve a mano
		drop_ref = mano_ref
	elif heldFrameCount <= 8: # lclick corto, a primer espacio desde mano
		if en_mano:
			drop_ref = first_available() 
	else:
		drop_ref = check_closest()

	if drop_ref != null: #en espacio dropeable
		if !en_mano:
			init_drop.is_empty = true
			init_drop.carta = null
		
		if drop_ref.is_in_group("mano"): 
			if en_mano:
				mano_ref.array_cartas.erase(self)
			en_espacio = mano_ref
			mano_ref.array_cartas.append(self)
			mano_ref.reordenar()
			
		elif heldFrameCount !=-1: #lclick corto o dragging
			if !drop_ref.is_empty: #intercambio de cartas
				drop_ref.carta.en_espacio = init_drop
				if en_mano:
					mano_ref.array_cartas.append(drop_ref.carta)
				else:
					init_drop.is_empty = false
					init_drop.carta = drop_ref.carta
					tween.tween_property(drop_ref.carta, "position", init_drop.position, drop_ref.position.distance_to(init_drop.position)/juego.vel).set_ease(Tween.EASE_OUT)
			
			if en_mano:
				mano_ref.array_cartas.erase(self)
				mano_ref.reordenar()
				
			en_espacio = drop_ref
			drop_ref.is_empty = false
			drop_ref.carta = self
			tween.tween_property(self, "position", drop_ref.position, init_drop.position.distance_to(drop_ref.position)/juego.vel).set_ease(Tween.EASE_OUT)

			
	else: #vuelve a la posicion inicial
		if init_drop.is_in_group("mano"):
			mano_ref.reordenar()
		else:
			tween.tween_property(self, "position", init_drop.position, init_drop.position.distance_to(position)/juego.vel).set_ease(Tween.EASE_OUT)
	juego.comprueba()



func first_available(): #devuelve primer espacio vacio
	for e in get_tree().get_nodes_in_group("dropable"):
		if !e.is_in_group("mano") and e.is_empty:
			return e;
	return null


func check_closest(): #devuelve espacio ocupado más cercano al centro de la carta
	var min_v = Vector2(2222,2222)
	var res = null
	for e in array_drops:
		var diff 
		if e.is_in_group("mano"):
			diff = Vector2(0,e.global_position.y - global_position.y)
		else:
			diff = abs(e.global_position - global_position)
		if diff < min_v:
			min_v = abs(e.global_position - global_position)
			res = e
	return res


#SIGNALS
func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group('dropable'):
		array_drops.append(body)
		

func _on_area_2d_body_exited(body: Node2D) -> void:
	if body.is_in_group('dropable'):
		array_drops.erase(body)
		body.modulate = Color(Color.MEDIUM_PURPLE, 0.7)


func _on_mouse_entered() -> void:
	if not juego.dragging:
		juego.ordena()
		get_parent().move_child(self,-1)#mover indice en z
		
		if self.get_index() == get_parent().get_child_count(false)-1:
			dragable= true
			if scale <= Vector2(0.22,0.22):
				scale += Vector2(0.01, 0.01)

			for c in get_parent().get_children(false):

				if c != self:
					c.dragable = false
					if c.scale > Vector2(0.22,0.22):
						c.scale -= Vector2(0.01, 0.01)
					


func _on_mouse_exited() -> void:#TODO on_mano_exited reordenar cartas
	if not juego.dragging:
		juego.ordena()
		dragable = false
		#get_parent().move_child(self,-1)#mover indice en z
		if scale > Vector2(0.22,0.22):
			scale -= Vector2(0.01, 0.01)
