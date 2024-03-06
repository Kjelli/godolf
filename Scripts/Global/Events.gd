extends Node

signal player_spawned(player : Player)

signal charge_updated(min_charge : float, current_charge : float, max_charge : float)

signal ball_shot(ball : Ball)
signal ball_stopped(ball : Ball)
signal ball_sunk(ball : Ball)
