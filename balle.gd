extends Node2D

var speed = 750

func _physics_process(delta):
	position -= transform.y * speed * delta

	
func _on_Bullet_body_entered(body: Node2D) -> void:
	if body.is_in_group("boids"):
		body.queue_free()  # supprimer l'ennemi
		queue_free()       # supprimer la balle


func _on_area_2d_body_entered(body: Node2D) -> void:
	if body.is_in_group("boids"):
		body.queue_free()  # supprimer l'ennemi
		queue_free()       # supprimer la balle
