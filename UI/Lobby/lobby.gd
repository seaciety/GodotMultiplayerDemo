extends Node2D

class_name Lobby

@onready var player_list: VBoxContainer = $VBoxContainer/PlayerList
@onready var start_button: Button = $VBoxContainer/StartButton

func _ready() -> void:
	for example_player in player_list.get_children():
		player_list.remove_child(example_player)
		example_player.queue_free()
	if !MultiplayerManager.is_host:
		start_button.visible = false
		MultiplayerManager.lobby_player_list_updated.connect(player_list_updated)
	if MultiplayerManager.is_host:
		MultiplayerManager.player_connected_to_lobby.connect(player_connected)
		MultiplayerManager.player_disconnected_from_lobby.connect(player_disconnected)
		MultiplayerManager.initial_lobby_update()
	
func player_list_updated(player_name_list: Array) -> void:
	for player_name: String in player_name_list:
		if player_is_already_on_list(player_name):
			continue
		player_connected(player_name)
	
	for player_on_list in player_list.get_children():
		if player_on_list.text not in player_name_list:
			player_disconnected(player_on_list.text)

func player_is_already_on_list(player_name: String) -> bool:
	for player_on_list in player_list.get_children():
		if player_on_list.text == player_name:
			return true
	return false

func player_connected(username: String) -> void:
	var new_label := Label.new()
	new_label.text = username
	player_list.add_child(new_label)

func player_disconnected(username: String) -> void:
	for label: Label in player_list.get_children():
		if label.text == username:
			player_list.remove_child(label)
			break

func _on_start_button_pressed() -> void:
	GameManager.start_game()

func _on_quit_button_pressed() -> void:
	GameManager.quit_to_menu()
