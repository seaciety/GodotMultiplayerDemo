extends Node

# The GameManager is a state machine that switches between scenes and calls transition functions as needed

enum game_state {
	MAIN_MENU,
	SERVER_LOBBY,
	HOST_LOBBY,
	CLIENT_LOBBY,
	SERVER_SETUP,
	HOST_SETUP,
	CLIENT_LOADING,
	MAIN_GAME_SERVER,
	MAIN_GAME_HOST,
	MAIN_GAME_CLIENT,
}

var current_state := game_state.MAIN_MENU

func start_server_lobby() -> void:
	if current_state != game_state.MAIN_MENU:
		return
	get_tree().change_scene_to_file("res://UI/Lobby/lobby.tscn")
	current_state = game_state.SERVER_LOBBY
	MultiplayerManager.setup_server_lobby()
	
func start_host_lobby(username: String) -> void:
	if current_state != game_state.MAIN_MENU:
		return
	get_tree().change_scene_to_file("res://UI/Lobby/lobby.tscn")
	current_state = game_state.HOST_LOBBY
	MultiplayerManager.setup_host_lobby(username)

func quit_to_menu() -> void:
	if current_state not in [game_state.SERVER_LOBBY, game_state.CLIENT_LOBBY, game_state.HOST_LOBBY]:
		return
	get_tree().change_scene_to_file("res://UI/MainMenu/menu.tscn")
	current_state = game_state.MAIN_MENU
	MultiplayerManager.reset()

func start_game() -> void:
	if current_state == game_state.SERVER_LOBBY:
		start_server_game()
		return
	if current_state == game_state.HOST_LOBBY:
		start_host_game()
		return

func start_server_game() -> void:
	if current_state != game_state.SERVER_LOBBY:
		return
	get_tree().change_scene_to_file("res://Game/MainGame.tscn")
	current_state = game_state.SERVER_SETUP
	
func start_host_game() -> void:
	if current_state != game_state.HOST_LOBBY:
		return
	get_tree().change_scene_to_file("res://Game/MainGame.tscn")
	current_state = game_state.HOST_SETUP
	
func server_game_ready() -> void:
	MultiplayerManager.setup_game_server()
	
func server_game_start() -> void:
	if current_state != game_state.SERVER_SETUP:
		return
	current_state = game_state.MAIN_GAME_SERVER
	MultiplayerManager.start_game_for_players()

func host_game_ready() -> void:
	MultiplayerManager.setup_game_host()

func host_game_start() -> void:
	if current_state != game_state.HOST_SETUP:
		return
	current_state = game_state.MAIN_GAME_HOST
	MultiplayerManager.start_game_for_players()

func join_lobby(ip_address: String, username: String) -> void:
	if current_state != game_state.MAIN_MENU:
		return
	get_tree().change_scene_to_file("res://UI/Lobby/lobby.tscn")
	current_state = game_state.CLIENT_LOBBY
	MultiplayerManager.join_lobby(ip_address, username)

func client_start_loading() -> void:
	if current_state != game_state.CLIENT_LOBBY:
		return
	get_tree().change_scene_to_file("res://UI/LoadScreen/Loading.tscn")
	current_state = game_state.CLIENT_LOADING
	
func client_game_started() -> void:
	if current_state != game_state.CLIENT_LOADING:
		return
	get_tree().change_scene_to_file("res://Game/MainGame.tscn")
	current_state = game_state.MAIN_GAME_CLIENT
