extends CharacterBody2D

var direction := Vector2.ZERO
var animationDir := Vector2.DOWN
const speed = 200
var stringAnimation = "Right"
var speedMultiplier = 1
var disableFootsteps = true

@onready var animationNode = $"Player Animations"
@onready var cameraNode = $"Camera"
@onready var colliderNode = $"Player Collider"

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
	var motionMode = handle_motion_actions()
	var stamina_delta = 16 + Player.time_spend_not_walking ** 2 * 4
	if motionMode == 1: stamina_delta = 8
	elif motionMode > 1:
		stamina_delta = -18 if LeafMode.enabled() else 0
	LeafMode.change_stamina(stamina_delta * delta)

func handle_motion_actions():
	if not Player.visible or TextSystem.lockAction: return 0
	direction = Vector2.ZERO
	
	speedMultiplier = 1
	if Input.is_action_pressed("move_left"):
		stringAnimation = "Left"
		animationDir = Vector2.LEFT
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		stringAnimation = "Right"
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
		if not LeafMode.enabled(): staminaPercentage = 1
		var fast_movement = 0.5
		if LeafMode.enabled(): fast_movement = 1
		speedMultiplier += fast_movement * staminaPercentage
	
	var previousPosition = position
	direction *= speedMultiplier
	direction.normalized()
	velocity = direction * speed
	move_and_slide()
	position = position.round()
	update_animations()
	if direction == Vector2.ZERO or previousPosition == position: return 0
	return speedMultiplier

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
	Audio.play_sound("res://Audio/SFX/Footsteps.mp3", 0.3, -5)
	disableFootsteps = true
	await get_tree().create_timer(randf_range(0.23, 0.26) / speedMultiplier).timeout
	disableFootsteps = false
