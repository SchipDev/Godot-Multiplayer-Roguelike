extends Area2D

var BULLET_SPEED = 250
var BULLET_DAMAGE = 25

func _physics_process(delta: float) -> void:
	position += transform.x * BULLET_SPEED * delta



func _on_body_entered(body: Node2D) -> void:
	if !is_multiplayer_authority():
		return
	if body.has_method("apply_damage"):
		body.apply_damage.rpc_id(body.get_multiplayer_authority(), BULLET_DAMAGE)
	destroy_bullet.rpc()

@rpc("call_local")
func destroy_bullet():
	queue_free()
