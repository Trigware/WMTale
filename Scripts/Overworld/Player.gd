extends CharacterBody2D

var direction := Vector2.ZERO
var basic_direction := Vector2.ZERO
var stringAnimation = "Right"
var is_left_last_horizontal_dir = false
var speedMultiplier = 1
var disableFootsteps = true
var latest_speed : float

@onready var animationNode = $"Sprite"
@onready var sprite = animationNode # animationNode alias for Inputless Movement
@onready var cameraNode = $"Camera"
@onready var colliderNode = $"Player Collider"

enum MovementMode {
	STILL,
	WALK,
	RUN
}

func enable():
	disableFootsteps = false
	TextSystem.fallbackPreset = TextSystem.Preset.RegularDialog
	animationNode.frame = 0
	cameraNode.enabled = true
	Player.show()

func disable():
	disableFootsteps = true
	cameraNode.enabled = false
	Player.hide()

func _process(delta):
	if not Player.visible: return
	var stamina_delta = 4 + (Player.maxStamina - Player.stamina) * Player.time_spend_not_walking / 2
	match handle_motion_actions():
		MovementMode.WALK: stamina_delta = 8
		MovementMode.RUN: stamina_delta = -20 if LeafMode.enabled() else 0
	LeafMode.change_stamina(stamina_delta * delta)

func handle_motion_actions():
	basic_direction = Vector2.ZERO
	if not Player.visible or TextSystem.lockAction or CutsceneManager.action_lock or LeafMode.game_over or SaveMenu.menu_openned or Player.inputless_movement:
		return MovementMode.STILL
	direction = Vector2.ZERO
	
	var movementMode = MovementMode.WALK
	speedMultiplier = 1
	if Input.is_action_pressed("move_left"):
		stringAnimation = "Left"
		is_left_last_horizontal_dir = true
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		stringAnimation = "Right"
		is_left_last_horizontal_dir = false
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		stringAnimation = "Up"
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		stringAnimation = "Down"
		direction.y += 1
	
	basic_direction = direction
	if Input.is_action_pressed("move_fast"):
		speedMultiplier = Player.get_fast_movement_speed()
		movementMode = MovementMode.RUN
	
	var previousPosition = position
	latest_speed = speedMultiplier * Player.player_speed
	take_step(direction, latest_speed)
	if direction == Vector2.ZERO or previousPosition == position: return MovementMode.STILL
	return movementMode

func take_step(dir, speed):
	direction = dir
	velocity = direction * speed
	move_and_slide()
	position = position.round()
	update_animations()
	return get_slide_collision_count() > 0

func update_animations():
	update_walk_animation_frame()
	if velocity == Vector2.ZERO:
		animationNode.stop()
		return
	add_to_footstep_targets()
	Player.time_spend_not_walking = 0.0
	on_footstep()
	animationNode.speed_scale = speedMultiplier
	Player.play_animation(get_walk_animation_name())

func get_walk_animation_name() -> String: return SaveData.selectedCharacter + "Walk" + stringAnimation
func get_general_animation_name(suffix) -> String: return SaveData.selectedCharacter + str(suffix)

func update_walk_animation_frame():
	animationNode.animation = get_walk_animation_name()

func on_footstep():
	if disableFootsteps: return
	play_footstep()
	disableFootsteps = true
	await get_tree().create_timer(randf_range(0.23, 0.26) / speedMultiplier).timeout
	disableFootsteps = false

func play_footstep():
	var footstep_type = UID.Footstep.Ground
	if Player.in_water: footstep_type = UID.Footstep.Water
	if Player.in_leaves: footstep_type = UID.Footstep.Leaves
	Audio.play_sound(UID.SFX_FOOTSTEPS[footstep_type], 0.3, -5)

func add_to_footstep_targets():
	Player.footstep_targets.append(global_position)
	MovingNPC.check_for_follower_movement()
