extends Area2D

# Represents the position and shape of a projectile when it hit a player as reported by a 
# client and to be verified by the server
class_name LagCompensationProjectile

@onready var collision_shape_2d := $CollisionShape2D

const max_ticks = 5

var actual_projectile: Projectile
var damage: int
var victim: LagCompensationPlayer

var ticks := 0

func _ready() -> void:
	if actual_projectile != null:
		collision_shape_2d = actual_projectile.collision_shape_2d.duplicate()

func _physics_process(_delta: float) -> void:
	if overlaps_area(victim):
		victim.actual_player.take_damage(damage)
		if actual_projectile != null:
			actual_projectile.damage = 0
			actual_projectile.remove()
		remove_pair()
		return
	if ticks > max_ticks:
		remove_pair()
	ticks += 1
	
func remove_pair() -> void:
	victim.queue_free()
	queue_free()
