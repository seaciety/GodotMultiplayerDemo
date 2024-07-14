extends Area2D

# Represents the position and shape of a player when it was hit by a projectile as reported by a 
# client and to be verified by the server
class_name LagCompensationPlayer

@onready var collision_shape_2d := $CollisionShape2D
var actual_player: Player

func _ready() -> void:
	if actual_player != null:
		collision_shape_2d = actual_player.collision_shape_2d.duplicate()
