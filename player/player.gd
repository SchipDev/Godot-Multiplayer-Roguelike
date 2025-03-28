class_name Player
extends CharacterBody2D

@onready var game: Game = get_parent()

const SPEED = 100.0
const JUMP_VELOCITY = -200.0
const MAX_HEALTH = 100
const BULLET = preload("res://player/bullet.tscn")

var current_health = MAX_HEALTH

func _enter_tree() -> void:
	set_multiplayer_authority(int(str(name)))

func _ready() -> void:
	if !is_multiplayer_authority():
		$Sprite2D.modulate = Color.RED

func _physics_process(delta: float) -> void:
	if !is_multiplayer_authority():
		return
	
	$GunContainer.look_at(get_global_mouse_position())
	if get_global_mouse_position().x < global_position.x:
		$GunContainer/GunSprite.flip_v = true
	else:
		$GunContainer/GunSprite.flip_v = false
	
	if Input.is_action_just_pressed("shoot"):
		shoot.rpc(multiplayer.get_unique_id())
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var direction := Input.get_axis("left", "right")
	if direction:
		velocity.x = direction * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)

	move_and_slide()

@rpc("call_local")
func shoot(shooter_pid):
	var bullet = BULLET.instantiate()
	# Play sound effect for shooting
	$GunContainer/AudioStreamPlayer2D.play()
	bullet.set_multiplayer_authority(shooter_pid)
	get_parent().add_child(bullet)
	bullet.transform = $GunContainer/GunSprite/ProjectileSpawnPoint.global_transform

@rpc("any_peer")
func apply_damage(damage: int) -> void:
	current_health -= damage
	if current_health <= 0:
		current_health = MAX_HEALTH
		global_position = game.get_random_spawn_point()
