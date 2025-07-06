extends CanvasLayer

var effect : Effects.ID

@onready var icon = $"Effect Icon"

func _ready():
	var effect_name = Effects.get_effect_name(effect)
	var effect_path = "res://Textures/Effects/" + effect_name + ".png"
	icon.texture = load(effect_path)
