extends Node2D

# This is the scene shown to clients when their clock is syncing with the server/host

@onready var loading_label := $CanvasLayer/LoadingLabel

const loading_text_rate := 20
var loading_text_count := 0

func _physics_process(_delta: float) -> void:
	loading_text_count += 1
	if loading_text_count == loading_text_rate:
		loading_text_count = 0
		loading_label.text += "."
