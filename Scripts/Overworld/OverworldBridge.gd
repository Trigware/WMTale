extends Node

func _ready():
	Overworld.enable()
	SaveData.load_game(1)
