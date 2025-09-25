extends Node2D

@export_range(3, 500, 2) var num_boids : int = 20  # Nombre cible de boids

@export var enable_separation : bool = false :
	set(value) :
		enable_separation = value
		update_forces()
		
@export var enable_alignment : bool = false  :
	set(value) :
		enable_alignment = value
		update_forces()		
		
@export var enable_cohesion : bool = false  :
	set(value) :
		enable_cohesion = value
		update_forces()

@onready var boid_scene = preload("res://ennemi.tscn")

func _ready():
	randomize()  # Initialisation aléatoire
	adjust_boids()  # Ajuste le nombre de boids initialement
	update_forces()

# Ajuste dynamiquement le nombre de boids pour correspondre à "num_boids"
func adjust_boids():
	var current_boids = get_children().filter(func(n): return n is Boid)
	var current_count = current_boids.size()

	if current_count < num_boids:
		# Ajouter des boids manquants
		add_boids(num_boids - current_count)
	elif current_count > num_boids:
		# Retirer des boids en excès
		remove_boids(current_count - num_boids)

# Ajouter les boids manquants
func add_boids(count: int):
	for i in range(count):
		var boid_instance = boid_scene.instantiate()
		boid_instance.position = Vector2(randf_range(0.0, get_viewport_rect().size.x), randf_range(0.0, get_viewport_rect().size.y))
		add_child(boid_instance)

# Retirer aléatoirement les boids en excès
func remove_boids(count: int):
	var current_boids = get_children().filter(func(n): return n is Boid)
	for i in range(count):
		var random_boid = current_boids[randi_range(0, current_boids.size() - 1)]
		current_boids.erase(random_boid)
		random_boid.queue_free()

	

# Cette fonction peut être appelée à tout moment pour ajuster le nombre de boids
func _process(delta):
	manage_inputs()
	
	# Appel d'ajustement pour synchroniser le nombre de boids si le champ change
	if num_boids != get_children().filter(func(n): return n is Boid).size():
		adjust_boids()

func manage_inputs() -> void :
	if (Input.is_action_just_pressed("quit")):
		get_tree().quit()
	
func update_forces() -> void :
	var current_boids = get_children().filter(func(n): return n is Boid)
	
	for boid in current_boids:
		boid.has_cohesion = enable_cohesion
		boid.has_alignment = enable_alignment
		boid.has_separation = enable_separation
