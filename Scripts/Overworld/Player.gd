extends CharacterBody2D

var direction := Vector2.ZERO
var animationDir := Vector2.DOWN
const speed = 250
var stringAnimation = "Right"
var is_left_last_horizontal_dir = false
var speedMultiplier = 1
var disableFootsteps = true

@onready var animationNode = $"Player Animations"
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
	if not Player.visible or TextSystem.lockAction or CutsceneManager.action_lock or LeafMode.game_over:
		return MovementMode.STILL
	direction = Vector2.ZERO
	
	var movementMode = MovementMode.WALK
	speedMultiplier = 1
	if Input.is_action_pressed("move_left"):
		stringAnimation = "Left"
		is_left_last_horizontal_dir = true
		animationDir = Vector2.LEFT
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		stringAnimation = "Right"
		is_left_last_horizontal_dir = false
		animationDir = Vector2.RIGHT
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		stringAnimation = "Up"
		animationDir = Vector2.UP
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		stringAnimation = "Down"
		animationDir = Vector2.DOWN
		direction.y += 1
	
	if Input.is_action_pressed("move_fast"):
		var staminaPercentage = Player.stamina / Player.maxStamina
		var fast_movement = 0.7
		if not LeafMode.enabled(): staminaPercentage = 0.6
		speedMultiplier += fast_movement * staminaPercentage
		movementMode = MovementMode.RUN
	
	var previousPosition = position
	take_step(direction)
	if direction == Vector2.ZERO or previousPosition == position: return MovementMode.STILL
	return movementMode

func take_step(dir):
	direction = dir
	direction *= speedMultiplier
	direction.normalized()
	velocity = direction * speed
	move_and_slide()
	position = position.round()
	update_animations()

func update_animations():
	update_walk_animation_frame()
	if velocity == Vector2.ZERO:
		animationNode.stop()
		return
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
	var base_footstep = "res://Audio/SFX/Footsteps"
	var footstep_sound = base_footstep
	if Player.in_water: footstep_sound = base_footstep + "Water"
	if Player.in_leaves: footstep_sound = base_footstep + "Leaves"
	Audio.play_sound(footstep_sound + ".mp3", 0.3, -5)
