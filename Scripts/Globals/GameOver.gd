extends CanvasLayer

const screen_width = 1152
const screen_height = 648

@onready var leaf = $Leaf

func _ready():
	Overworld.disable()
	Overlay.set_alpha(0)
	leaf.position += Vector2(screen_width, screen_height) / 2
	await get_tree().create_timer(1).timeout
	LeafMode.game_over = false
	Audio.play_sound("res://Audio/SFX/LeafBreak.mp3")
	leaf.play()
	await get_tree().create_timer(0.5).timeout
	game_over_dialog()

func game_over_dialog():
	pass
