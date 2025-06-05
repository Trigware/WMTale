extends CharacterBody2D

var direction = Vector2.ZERO
const speed = 200
var stringAnimation = "Down"
var speedMultiplier = 1
var disableFootsteps = false

@onready var animationNode = $"Player Animations"

func _ready():
	TextSystem.fallbackPreset = TextSystem.Preset.RegularDialog
	update_animation_frame()
	animationNode.frame = 0

func _process(_delta):
	if TextSystem.lockAction:
		animationNode.stop()
		return
	direction = Vector2.ZERO
	speedMultiplier = 1
	if Input.is_action_pressed("move_left"):
		stringAnimation = "Left"
		direction.x -= 1
	if Input.is_action_pressed("move_right"):
		stringAnimation = "Right"
		direction.x += 1
	if Input.is_action_pressed("move_up"):
		stringAnimation = "Up"
		direction.y -= 1
	if Input.is_action_pressed("move_down"):
		stringAnimation = "Down"
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
	update_animation_frame()
	if velocity == Vector2.ZERO:
		animationNode.stop()
		return
	on_footstep()
	animationNode.speed_scale = speedMultiplier
	animationNode.play(get_animation_name())

func get_animation_name() -> String: return SaveData.selectedCharacter + "Walk" + stringAnimation

func update_animation_frame():
	animationNode.animation = get_animation_name()

func on_footstep():
	if disableFootsteps: return
	Audio.play_sound("res://Audio/SFX/Footsteps.mp3", 0.3, 0)
	disableFootsteps = true
	await get_tree().create_timer(randf_range(0.23, 0.26) / speedMultiplier).timeout
	disableFootsteps = false
