extends Node

# Network related
signal handshake_received(handshake : Handshake)
signal someone_disconnected(player_id : int, player_name : String)

# In game
signal player_spawned(player : Player)
signal player_authority_changed(player : Player, player_id : int)

signal charge_updated(player_id : int, min_charge : float, current_charge : float, max_charge : float)

signal ball_shot(ball : Ball)
signal ball_stopped(ball : Ball)
signal ball_sunk(ball : Ball)
