extends Node2D

@onready var name_line_edit := $VBoxContainer/NameHBoxContainer/NameLineEdit
@onready var ip_address_line_edit := $VBoxContainer/IPAddressHBoxContainer/IPAddressLineEdit

const default_names := ["Spongebob", "Patrick", "Plankton", "Mr. Krabs", "Pearl", "Larry", "Squidward", "Mrs. Puff", "Sandy", "Gary", "Squilliam"]

func _on_server_pressed() -> void:
	GameManager.start_server_lobby()

func _on_join_pressed() -> void:
	GameManager.join_lobby(ip_address_line_edit.text, get_username())

func _on_host_pressed() -> void:
	GameManager.start_host_lobby(get_username())

func get_username() -> String:
	var username : String = name_line_edit.text
	if username == "":
		randomize()
		username = default_names[randi() % default_names.size()]
	return username
