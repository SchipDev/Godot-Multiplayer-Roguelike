extends Node

@onready var multiplayer_ui = $UI/Multiplayer

const DEFAULT_PORT = 25565
const PLAYER_SCENE = preload("res://player/player.tscn")

var peer = ENetMultiplayerPeer.new()

func _on_host_pressed() -> void:
	peer.create_server(DEFAULT_PORT)
	multiplayer.multiplayer_peer = peer
	
	multiplayer.peer_connected.connect(
		func(pid):
			print("Peer " + str(pid) + " has joined the game!")
			add_player(pid)
	)
	
	add_player(multiplayer.get_unique_id())
	multiplayer_ui.hide()


func _on_join_pressed() -> void:
	peer.create_client("localhost", DEFAULT_PORT)
	multiplayer.multiplayer_peer = peer
	multiplayer_ui.hide()
	

func add_player(pid):
	var player = PLAYER_SCENE.instantiate()
	player.name = str(pid)
	add_child(player)
	print("Player", pid, "spawned at:", player.position)
