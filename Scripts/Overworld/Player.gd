extends CharacterBody2D

var direction = Vector2.ZERO
const speed = 200
var stringAnimation = "Down"
var speedMultiplier = 1

@onready var animationNode = $"Player Animations"

func _ready():
	animationNode.animation = get_animation_name()
	animationNode.frame = 0

func _process(_delta):
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
	update_animations()

func update_animations():
	if direction == Vector2.ZERO:
		animationNode.stop()
		return
	animationNode.speed_scale = speedMultiplier
	animationNode.play(get_animation_name())

func get_animation_name() -> String: return SaveData.selectedCharacter + "Walk" + stringAnimation
