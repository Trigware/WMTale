extends Node

func play_sound(sound_path):
	var stream = load(sound_path)
	if not stream:
		push_error("Unable to play sound at path " + sound_path + "!")
		return
	
	var player = AudioStreamPlayer.new()
	player.stream = stream
	add_child(player)
	player.play()

	player.finished.connect(func():
		player.queue_free()
	)
