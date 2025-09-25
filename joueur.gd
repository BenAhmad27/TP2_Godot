extends CharacterBody2D

@export var speed := 300
var screen_size : Vector2
var bullet_scene : PackedScene = preload("res://balle.tscn")
var  max_bullets := 10

func _ready():
	screen_size = get_viewport_rect().size
	position = Vector2(screen_size.x / 2, screen_size.y - 50)

func _physics_process(delta):
	var input_dir = 0.0
	
	if Input.is_action_pressed("ui_left") or Input.is_action_pressed("gauche"):
		input_dir -= 1
	if Input.is_action_pressed("ui_right")or Input.is_action_pressed("droite"):
		input_dir += 1

	position.x += input_dir * speed * delta
	position.x = clamp(position.x, 0, screen_size.x)
	
	var collision = move_and_collide(velocity * delta)
	if collision:
		if collision.get_collider().is_in_group("boids"):
			die()

	# Tir avec espace
	if Input.is_action_just_pressed("tirer"):
		#if get_tree().get_nodes_in_group("bullets").size() < max_bullets:
			shoot()

func shoot():
	var bullet = bullet_scene.instantiate()
	bullet.position = position
	get_tree().current_scene.add_child(bullet)
	bullet.add_to_group("bullets")
	

			
func die():
	print("Game Over !")
	queue_free()   # supprime le joueur
	get_tree().reload_current_scene()  #pour recommencer
