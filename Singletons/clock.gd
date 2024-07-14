extends Node

# This is a clock for both the client and the server/host. The client's clock attempt to run ahead 
# of the server's clock by a fixed amount to facilitate client prediction/reconcillation and lag 
# compensation.

##################################################################################################
# Tunable consts
##################################################################################################

const ideal_client_tick_buffer := 9
const min_client_server_tick_diff := 6
const max_client_server_tick_diff := 20
const sync_period_ms := 100
const averaging_sample_size := 10

##################################################################################################
# Shared variables
##################################################################################################

var tick := 0

##################################################################################################
# Client variables
##################################################################################################

var tick_adjustment := 0
var average_latency_in_ticks := 0
var sync_timer : Timer = null
var last_offsets := []

##################################################################################################
# Shared functions
##################################################################################################

func _ready() -> void:
	process_physics_priority = -100
	
func _physics_process(_delta: float) -> void:
	advance_tick()

func advance_tick() -> void:
	tick += 1 + tick_adjustment
	tick_adjustment = 0
	
static func ms_to_ticks(ms: int) -> int:
	return (int) (ceil( (ms / 1000.0) * Engine.physics_ticks_per_second))

##################################################################################################
# Client functions
##################################################################################################

func start_sync() -> void:
	initial_sync.rpc_id(1)
	start_periodic_sync()
	
@rpc("reliable")
func reset_tick(tick_: int) -> void:
	tick = tick_

func start_periodic_sync() -> void:
	if sync_timer != null:
		return
	sync_timer = Timer.new()
	sync_timer.wait_time = sync_period_ms / 1000.0
	sync_timer.one_shot = false
	sync_timer.connect("timeout", send_sync_packet)
	add_child(sync_timer)
	sync_timer.start()

# called every sync_period_ms
func send_sync_packet() -> void:
	server_receive_sync_packet.rpc_id(1, Time.get_ticks_msec())

@rpc("unreliable")
func client_receive_sync_packet(client_time: int, server_tick: int) -> void:
	last_offsets.push_front(calc_offset(Time.get_ticks_msec(), client_time, server_tick, tick, ideal_client_tick_buffer, min_client_server_tick_diff, max_client_server_tick_diff))
	
	if len(last_offsets) > averaging_sample_size:
		var sum := 0
		for each: int in last_offsets:
			sum += each
		tick_adjustment = (int) (ceil((sum / len(last_offsets) )))
		last_offsets = []

static func calc_offset(local_time_ms: int,
						client_sync_packet_time_ms: int,
						server_tick: int,
						client_tick: int,
						ideal_client_tick_buffer_: int,
						min_client_server_tick_diff_: int,
						max_client_server_tick_diff_: int) -> int:
	var instantaneous_latency_in_ms := (local_time_ms - client_sync_packet_time_ms) / 2
	var instantaneous_latency_in_ticks := ms_to_ticks(instantaneous_latency_in_ms)
	MultiplayerManager.ping_in_ms = instantaneous_latency_in_ms
	# the formula we are trying to achieve is the below:
	# client_tick - server_tick = latency_in_ticks + client_tick_buffer
	var client_tick_buffer := client_tick - server_tick - instantaneous_latency_in_ticks
	if client_tick_buffer < min_client_server_tick_diff_ or  client_tick_buffer > max_client_server_tick_diff_:
		return ideal_client_tick_buffer_ - client_tick_buffer
	return 0

##################################################################################################
# Server functions
##################################################################################################

@rpc("any_peer", "call_remote", "reliable")
func initial_sync() -> void:
	reset_tick.rpc_id(multiplayer.get_remote_sender_id(), tick)

@rpc("any_peer", "call_remote", "unreliable")
func server_receive_sync_packet(client_time: int) -> void:
	client_receive_sync_packet.rpc_id(multiplayer.get_remote_sender_id(), client_time, tick)
