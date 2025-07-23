extends Area2D

@export var cutscene: CutsceneManager.Cutscene

func _ready():
	if cutscene == CutsceneManager.Cutscene.None:
		push_error("Cutscene not initialized!")

func _on_cutscene_triggered(body: Node2D) -> void:
	if not body.is_in_group("Player"): return
	CutsceneManager.let_cutscene_play_out(cutscene)
