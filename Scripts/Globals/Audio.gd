extends Node

signal finished

func play_sound(sound_path, pitch_shift = 0):
	var stream = load(sound_path)
	play_stream(stream, pitch_shift)

func play_stream(stream, pitch_shift = 0):
	if not stream: return
	var player = AudioStreamPlayer.new()
	player.stream = stream
	
	var direction = -1 if randf() < 0.5 else 1
	var shiftAmount = randf_range(0, pitch_shift)
	var randomPitch = 1 + direction * shiftAmount
	player.pitch_scale = max(0.01, randomPitch)
	
	add_child(player)
	player.play()

	player.finished.connect(func():
		player.queue_free()
		emit_signal("finished")
	)
