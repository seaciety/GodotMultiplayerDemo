extends Control

@onready var health := $Health

func update_health(new_health: int) -> void:
	health.text = "health: " + str(new_health)
