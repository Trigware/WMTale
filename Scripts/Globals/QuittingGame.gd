extends Control

@onready var quitText = $"Front Layer/Quit Text"
@onready var blackScreen = $"Front Layer/Black Screen"

var quitStopwatch := 0.0
const transparencyChangePerProcessCall = 0.035

func _process(delta: float):
	if Input.is_action_pressed("quit_game"):
		quitStopwatch += delta
		var roundedTime = min(round(quitStopwatch * 4), 3)
		if quitStopwatch >= 1:
			on_game_close()
		
		quitText.modulate.a = min(1, quitText.modulate.a + transparencyChangePerProcessCall)
		var baseText = Localization.get_text("quitting_game")
		for i in range(0, roundedTime):
			baseText += "."
		quitText.text = baseText

	else:
		quitStopwatch = 0
		quitText.modulate.a = max(0, quitText.modulate.a - transparencyChangePerProcessCall)
	
func on_game_close():
	SaveData.save_autosave_file()
	if OS.get_name() == "Web":
		await get_tree().process_frame
		blackScreen.modulate.a = 1
	get_tree().quit()
