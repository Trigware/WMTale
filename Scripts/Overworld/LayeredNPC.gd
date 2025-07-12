extends Node2D

@onready var triggerArea = $"Trigger Area"
@export var treeSprite : Node2D

func _ready():
	if treeSprite is AnimatedSprite2D:
		var anim_name = "Tree"
		if anim_name in treeSprite.sprite_frames.get_animation_names():
			treeSprite.play("Tree")

func _process(_delta):
	var bodies = triggerArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			treeSprite.z_index = 100
			return
	treeSprite.z_index = 0
