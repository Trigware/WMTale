extends Control

@onready var fadeOverlay = $CanvasLayer/Overlay

var activeTween: Tween
var sceneChangingDisabled = false
signal finished

func _ready():
	fadeOverlay.color.a = 0

func hide_overlay():
	fadeOverlay.color.a = 1

func show_overlay():
	fadeOverlay.color.a = 0

func show_scene(duration = 1.0):
	overlay_tween(0, duration)

func hide_scene(duration = 1.0):
	overlay_tween(1, duration)

func overlay_tween(final: int, duration = 1):
	if activeTween != null and is_instance_valid(activeTween):
		activeTween.kill()
	activeTween = create_tween()
	activeTween.tween_property($CanvasLayer/Overlay, "color:a", final, duration)
	await activeTween.finished
	emit_signal("finished")
	
func change_scene(scene, hideDuration = 1, showDuration = 1, betweenSceneWait: float = 0):
	if sceneChangingDisabled: return
	sceneChangingDisabled = true
	hide_scene(hideDuration)
	await finished
	if betweenSceneWait > 0:
		await get_tree().create_timer(betweenSceneWait).timeout
	TextSystem.clear_text()
	if SaveData.allow_game_load:
		load_post_legend_scene()
	else:
		get_tree().change_scene_to_file(scene)
	show_scene(showDuration)
	await finished
	sceneChangingDisabled = false

func load_post_legend_scene():
	var nextScenePath = "res://Scenes/ChooseCharacter.tscn"
	if CutsceneManager.is_cutscene_finished(CutsceneManager.Cutscene.ChoosePlayer):
		Overworld.enable()
		nextScenePath = "res://Scenes/Audio.tscn" # empty scene
	if Overworld.saveFileCorrupted: nextScenePath = "res://Rooms/ErrorHandler.tscn"
	get_tree().change_scene_to_file(nextScenePath)
