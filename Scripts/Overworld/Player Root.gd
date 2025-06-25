extends Node

@onready var node = $"Player Body"

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
