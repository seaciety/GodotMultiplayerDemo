extends Area2D

class_name Projectile

@onready var collision_shape_2d := $CollisionShape2D

##################################################################################################
# Shared variables
##################################################################################################
var velocity := Vector2(0,0)
var damage := 25
var time_to_live := 3.0
var owner_id := 1
var id: int

##################################################################################################
# Client variables
##################################################################################################
var owned_by_this_player := false

##################################################################################################
# Server variables
##################################################################################################
# used for collision lag compensation
var previous_positions := {}

##################################################################################################
# Shared functions
##################################################################################################
func _ready() -> void:
	$TTLTimer.start(time_to_live)

func _physics_process(delta: float) -> void:
	position = apply_physics(delta)
	previous_positions[Clock.tick] = position

func apply_physics(delta: float) -> Vector2:
	return position + (delta * velocity)

func _on_ttl_timer_timeout() -> void:
	remove()

func remove() -> void:
	queue_free()
	if MultiplayerManager.is_host:
		MultiplayerManager.remove_projectile(self)

func _on_body_entered(body: Node2D) -> void:
	if body.collision_layer == 1 and body.id == owner_id:
		return
	if body.collision_layer == 1:
		body.take_damage(damage)
		if owned_by_this_player:
			MultiplayerManager.report_hit(id, body.id, owner_id)
	remove()
