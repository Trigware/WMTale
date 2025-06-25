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

func _process(_delta):
	if not Player.visible or TextSystem.lockAction: return
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
		speedMultiplier = 1.5
	
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
