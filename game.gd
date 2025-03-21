class_name Game
extends Node

@onready var multiplayer_ui = $UI/Multiplayer

const DEFAULT_PORT = 25565
const PLAYER_SCENE = preload("res://player/player.tscn")

var peer = ENetMultiplayerPeer.new()
var players: Array[Player] = []

func _ready() -> void:
	$MultiplayerSpawner.spawn_function = add_player

func _on_host_pressed() -> void:
	peer.create_server(DEFAULT_PORT)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game!")
			$MultiplayerSpawner.spawn(pid)
	)
	
	$MultiplayerSpawner.spawn(multiplayer.get_unique_id())
	multiplayer_ui.hide()


func _on_join_pressed() -> void:
	peer.create_client("localhost", DEFAULT_PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer_ui.hide()
	

func add_player(pid):
	var player = PLAYER_SCENE.instantiate()
	player.name = str(pid)
	player.global_position = $Level.get_child(players.size()).global_position
	players.append(player)
	return player

func get_random_spawn_point():
	return $Level.get_children().pick_random().global_position
