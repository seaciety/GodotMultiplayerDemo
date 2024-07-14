extends Node2D

# The main scene that runs the simulation for both the client and the server/host.

class_name MainGame

const Projectile = preload("res://Game/Projectile/projectile.tscn")
const GameState = preload("res://Game/proto/game_state.gd")

const ping_update_rate := 60
var ping_update_count := 0
var other_players := {}
var other_player_projectiles := {}
var local_player: Player = null

@onready var hud := $CanvasLayer/Hud

##################################################################################################
# Shared functions
##################################################################################################

func _ready() -> void:
	MultiplayerManager.ping_calculated.connect(set_ping)
	MultiplayerManager.player_added.connect(add_player)
	MultiplayerManager.player_removed.connect(remove_player)
	MultiplayerManager.player_updated.connect(update_player)
	MultiplayerManager.projectile_added_proto.connect(add_projectile_proto)
	MultiplayerManager.projectile_added.connect(add_projectile)
	MultiplayerManager.lag_compensation_player_added.connect(add_lag_compensation_player)
	MultiplayerManager.lag_compensation_projectile_added.connect(add_lag_compensation_projectile)
	if MultiplayerManager.player != null:
		local_player = MultiplayerManager.player
		local_player.health_updated.connect(update_health_in_hud)
		local_player.add_projectile.connect(add_projectile)
		add_child(local_player)
	if MultiplayerManager.is_server:
		var camera := Camera2D.new()
		get_tree().root.add_child(camera)
		camera.make_current()
		GameManager.server_game_ready()
		return
	if MultiplayerManager.is_host:
		GameManager.host_game_ready()
		
		
##################################################################################################
# Client functions
##################################################################################################

func set_ping(ping_in_ms: int) -> void:
	if ping_update_count == ping_update_rate:
		$CanvasLayer/Hud/Ping.text = str(snapped(ping_in_ms, 1)) + " ms"
		ping_update_count = 0
	else:
		ping_update_count += 1

func add_player(new_player: Player) -> void:
	other_players[new_player.id] = new_player
	add_child(new_player)

func update_player(p: GameState.GameState.PlayerProto) -> void:
	other_players[p.get_id()].set_username(p.get_username())
	other_players[p.get_id()].position.x = p.get_position_x()
	other_players[p.get_id()].position.y = p.get_position_y()
	other_players[p.get_id()].state = p.get_state()

func remove_player(player_id: int) -> void:
	if player_id in other_players:
		remove_child(other_players[player_id])
		other_players[player_id].queue_free()
		other_players.erase(player_id)

func add_projectile_proto(p: GameState.GameState.ProjectileProto) -> void:
	var new_projectile := Projectile.instantiate()
	new_projectile.id = p.get_id()
	new_projectile.owner_id = p.get_owner_id()
	new_projectile.damage = p.get_damage()
	new_projectile.position = Vector2(p.get_position_x(), p.get_position_y())
	new_projectile.velocity = Vector2(p.get_velocity_x(), p.get_velocity_y())
	if p.get_owner_id() not in other_player_projectiles:
		other_player_projectiles[p.get_owner_id()] = {}
	other_player_projectiles[p.get_owner_id()][p.get_id()] = new_projectile
	add_child(new_projectile)

func update_health_in_hud(new_health: int) -> void:
	hud.update_health(new_health)

##################################################################################################
# Server functions
##################################################################################################
func add_projectile(p: Projectile) -> void:
	add_child(p)

func add_lag_compensation_player(p: LagCompensationPlayer) -> void:
	add_child(p)

func add_lag_compensation_projectile(p: LagCompensationProjectile) -> void:
	add_child(p)
