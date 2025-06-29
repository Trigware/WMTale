extends Node

@onready var node = $"Player Body"
@onready var light = $"Player Body/Light"
@onready var leafNode = $"Player Body/Leaf"

var playerMaxHealth = 138
var playerHealth = playerMaxHealth
var maxStamina = 100
var stamina = maxStamina

var leafTween : Tween
var time_spend_not_walking := 0.0

func _ready():
	var current_flash_final = 1
	while true:
		leafTween = create_tween()
		var duration = lerp(0.1, 4.0, Player.playerHealth / Player.playerMaxHealth)
		leafTween.tween_property(leafNode, "modulate:v", current_flash_final, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
		current_flash_final = 0.5 if current_flash_final == 1 else 1
		await leafTween.finished

func _process(delta):
	time_spend_not_walking += delta

func enable():
	node.enable()

func disable():
	node.disable()

func get_global_pos() -> Vector2:
	return node.colliderNode.global_position

func update_animation(suffix):
	node.animationNode.animation = node.get_general_animation_name(suffix)

func play_general_animation(suffix):
	await play_animation(node.get_general_animation_name(suffix))

func play_animation(anim_name):
	var animatedSprite = node.animationNode
	animatedSprite.play(anim_name)

func set_pos(pos: Vector2):
	node.global_position = pos

func tween_color(final):
	create_tween().tween_property(node, "modulate", final, 1)

func tween_light_energy(final):
	create_tween().tween_property(light, "energy", final, 1)
	
func tween_leaf_alpha(final):
	create_tween().tween_property(leafNode, "modulate:a", final, 1)

func tween_value(final):
	create_tween().tween_property(node, "modulate:v", final, 1)

func sink_underwater():
	pass
