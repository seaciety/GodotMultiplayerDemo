extends GutTest

const clock = preload("res://Singletons/clock.gd")

const ideal_client_tick_buffer := 9
const min_client_server_tick_diff := 6
const max_client_server_tick_diff := 20

func test_ms_to_ticks() -> void:
	assert_eq(clock.ms_to_ticks(50), 3)
	assert_eq(clock.ms_to_ticks(1000), 60)

func test_calc_offset_clientBehind() -> void:
	# within buffer range of 6 to 20:
	# client_tick - server_tick - latency = 12 - 1 - 3 <50 ms> = 8
	assert_eq(clock.calc_offset(200, 100, 1, 12, ideal_client_tick_buffer, min_client_server_tick_diff, max_client_server_tick_diff), 0)
	
	# client clock too slow
	# client_tick - server_tick - latency = 2 - 1 - 3 <50 ms> = -2 (+11 to get to ideal of 9)
	assert_eq(clock.calc_offset(200, 100, 1, 2, ideal_client_tick_buffer, min_client_server_tick_diff, max_client_server_tick_diff), 11)
	
	# client clock too fast
	# client_tick - server_tick - latency = 25 - 1 - 3 <50 ms> = 26 (-17 to get to ideal of 9)
	assert_eq(clock.calc_offset(200, 100, 1, 30, ideal_client_tick_buffer, min_client_server_tick_diff, max_client_server_tick_diff), -17)

