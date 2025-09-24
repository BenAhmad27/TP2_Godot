extends CharacterBody2D

@export var speed := 300
var screen_size : Vector2
var bullet_scene : PackedScene = preload("res://balle.tscn")

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

	# Tir avec espace
	if Input.is_action_just_pressed("tirer"):
		shoot()

func shoot():
	var bullet = bullet_scene.instantiate()
	get_parent().add_child(bullet)
	bullet.position = position
