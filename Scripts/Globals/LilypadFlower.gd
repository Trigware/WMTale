extends Node2D

@export var texture_str : String
@onready var sprite = $"NPC Root/Sprite"

func _ready():
	var texture_name = "res://Textures/Weird Forest/Lilypad Flower " + texture_str + ".png"
	sprite.texture = load(texture_name)
