extends CharacterBody2D

@export var speed = 200
var bullet_scene : PackedScene = preload("res://balle.tscn")

func get_input():
	var dir = Input.get_vector("gauche", "droite", "avancer", "reculer")
	velocity = dir * speed
	
	if Input.is_action_just_pressed("tirer"):
		shoot()
	
	
func _physics_process(delta):
	get_input()
	
	move_and_slide()
	
func shoot():
	var b = bullet_scene.instantiate()
	get_parent().add_child(b)
	b.global_transform = $Muzzle.global_transform
	
	
	
