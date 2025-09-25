extends CharacterBody2D
class_name Boid

# --- Paramètres de base ---
var max_neighbor : int = 7
var top_speed : float = 150.0
var top_steer : float = 2
var mass : float = 1.0
var r : float = 10.0

var radius_separation : float = 5 * r
var radius_alignment : float = 10 * r
var radius_cohesion : float = 15 * r

@export_range(1, 3, 0.25) var weight_separation : float = 2
@export_range(1, 3, 0.25) var weight_alignment : float = 1.0
@export_range(1, 3, 0.25) var weight_cohesion : float = 1.0

var location : Vector2 = Vector2()
var acceleration : Vector2 = Vector2()

var has_cohesion : bool = true
var has_separation : bool = true
var has_alignment : bool = true

@onready var sprite = $Image

# --- Limite pour ne pas toucher le sol ---
var y_min : float = 50.0

# --- Respawn ---
var respawn_timer : Timer = Timer.new()
var is_dead : bool = false

# --- Initialisation ---
func _ready():
	randomize()
	velocity = Vector2(randf_range(-top_speed, top_speed), randf_range(-top_speed, top_speed))
	velocity.limit_length(top_speed)
	location.x = randi_range(0, get_viewport_rect().size.x as int)
	location.y = randi_range(y_min, get_viewport_rect().size.y as int)
	add_to_group("boids")

	# Configurer Timer pour respawn
	respawn_timer.wait_time = 5  # 5 secondes
	respawn_timer.one_shot = true
	respawn_timer.connect("timeout", Callable(self, "_respawn"))
	add_child(respawn_timer)

# --- Mise à jour à chaque frame ---
func _process(delta):
	if is_dead:
		return

	var boids = get_boid_siblings()
	
	if has_separation:
		apply_force(separation(boids) * weight_separation)
	if has_alignment:
		apply_force(alignment(boids) * weight_alignment)
	if has_cohesion:
		apply_force(cohesion(boids) * weight_cohesion)

	update_position(delta)
	wrap_around_screen()

	# Ne pas toucher le sol
	if location.y < y_min:
		location.y = y_min
		velocity.y = abs(velocity.y)

	if velocity.length() > 0:
		rotation = velocity.angle()
	queue_redraw()

# --- Appliquer une force ---
func apply_force(force: Vector2):
	acceleration += force / mass

# --- Mettre à jour la position ---
func update_position(delta):
	velocity += acceleration
	velocity = velocity.limit_length(top_speed)
	location += velocity * delta
	acceleration = Vector2()
	position = location

# --- Wrap autour de l'écran ---
func wrap_around_screen():
	if location.x > get_viewport_rect().size.x:
		location.x = 0
	elif location.x < 0:
		location.x = get_viewport_rect().size.x

	if location.y > get_viewport_rect().size.y:
		location.y = 0
	elif location.y < y_min:
		location.y = y_min

# --- Séparation ---
func separation(boids: Array) -> Vector2:
	var steer : Vector2 = Vector2()
	var total : int = 0
	for other in boids:
		var distance = location.distance_to(other.position)
		if distance < radius_separation and other != self:
			var diff = location - other.position
			diff = diff.normalized() / distance
			steer += diff
			total += 1
		if total > max_neighbor - 1:
			break
	if total > 0:
		steer /= total
		steer = steer.normalized() * top_speed - velocity
		steer = steer.limit_length(top_steer)
	return steer

# --- Alignement ---
func alignment(boids: Array) -> Vector2:
	var average_velocity = Vector2()
	var total = 0
	for other in boids:
		var distance = location.distance_to(other.position)
		if distance < radius_alignment and other != self:
			average_velocity += other.velocity
			total += 1
		if total > max_neighbor - 1:
			break
	if total > 0:
		average_velocity /= total
		average_velocity = average_velocity.normalized() * top_speed
		var steer = average_velocity - velocity
		steer = steer.limit_length(top_steer)
		return steer
	return Vector2()

# --- Cohésion ---
func cohesion(boids: Array) -> Vector2:
	var average_position = Vector2()
	var total = 0
	for other in boids:
		var distance = location.distance_to(other.position)
		if distance < radius_cohesion and other != self:
			average_position += other.position
			total += 1
		if total > max_neighbor - 1:
			break
	if total > 0:
		average_position /= total
		return seek(average_position)
	return Vector2()

# --- Seek cible ---
func seek(target: Vector2) -> Vector2:
	var desired = (target - location).normalized() * top_speed
	var steer = desired - velocity
	steer = steer.limit_length(top_steer)
	return steer

# --- Récupérer tous les boids ---
func get_boid_siblings() -> Array:
	var boids = []
	for sibling in get_parent().get_children():
		if sibling is Boid:
			boids.append(sibling)
	return boids

# --- Disparition / mort ---
func die():
	is_dead = true
	hide()
	respawn_timer.start()

# --- Respawn après timer ---
func _respawn():
	location.x = randi_range(0, get_viewport_rect().size.x as int)
	location.y = randi_range(y_min, get_viewport_rect().size.y as int)
	velocity = Vector2(randf_range(-top_speed, top_speed), randf_range(-top_speed, top_speed))
	show()
	is_dead = false
