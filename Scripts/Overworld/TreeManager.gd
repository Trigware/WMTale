extends Node2D

@onready var triggerArea = $"Trigger Area"
@onready var treeSprite = $"Tree Sprite"

func _ready():
	treeSprite.play("Tree")

func _process(_delta):
	var bodies = triggerArea.get_overlapping_bodies()
	for body in bodies:
		if body.is_in_group("Player"):
			treeSprite.z_index = 100
			return
	treeSprite.z_index = 0
