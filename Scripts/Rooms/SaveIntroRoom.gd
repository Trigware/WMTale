extends "res://Scripts/Overworld/BaseRoom.gd"

@onready var nixie = $Nixie

func _ready():
	SaveMenu.game_saved.connect(on_game_saved)
	SaveMenu.game_saved_menu_closed.connect(on_save_menu_closed_when_game_saved)

func on_game_saved():
	nixie.play_current()

func on_save_menu_closed_when_game_saved():
	CutsceneManager.let_cutscene_play_out(CutsceneManager.Cutscene.Nixie_Introductory)

func wait(time: float):
	await get_tree().create_timer(time).timeout
