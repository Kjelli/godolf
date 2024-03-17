extends Node

# Network related
signal handshake_received(handshake : Handshake)
signal someone_disconnected(player_id : int, player_name : String)

# Lobby transition
signal game_start_requested(game_descriptor : GameDescriptor)
signal game_proceeding
signal game_over

# hud related
signal local_player_idle
signal local_player_swinging
signal charge_updated(player_id : int, min_charge : float, current_charge : float, max_charge : float)
signal charge_interrupted(player_id : int)

# In game
signal player_spawned(player : Player)
signal player_authority_changed(player : Player, player_id : int)

signal ball_shot(ball : Ball)
signal ball_stopped(ball : Ball)
signal ball_sunk(player_id : int, player_name : String, times_hit : int)

signal player_score_updated(player_score : PlayerScore)
