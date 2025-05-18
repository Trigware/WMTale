extends Control

func _process(_delta: float):
	if Input.is_anything_pressed():
		var tween = create_tween()
		tween.tween_property($CanvasLayer/Overlay, "color", Color.BLACK, 1)
		await tween.finished
		await get_tree().process_frame
		get_tree().change_scene_to_file("res://Scenes/Legend.tscn")
