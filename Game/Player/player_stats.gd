extends Node

class BaseChar:
	#defense related stats
	var max_health := 100
	
	#movement related stats	
	var speed := 200
	var jump_gravity := 1000
	var fall_gravity := 2200
	var terminal_velocity := 1000
	var jump_speed := 600
	var jump_time := 0.35
	
	#attack related stats
	var attack_recharge_time := 0.2
	var projectile_time := 5
	var projectile_speed := 500
	var projectile_damage := 25
