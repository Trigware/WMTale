extends Node

signal finished

var waiting_for_stream = false

func play_sound(sound_path, pitch_shift = 0.0, volume = 0.0):
	var stream = load(sound_path)
	play_stream(stream, pitch_shift, volume)

func play_stream(stream, pitch_shift = 0.0, volume = 0.0):
	if not stream: return
	var player = AudioStreamPlayer.new()
	player.stream = stream
	
	player.volume_db  = volume
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

func play_awaited_stream(stream, pitch_shift = 0.0, volume = 0.0):
	if waiting_for_stream: return
	waiting_for_stream = true
	play_stream(stream, pitch_shift, volume)
	await finished
	waiting_for_stream = false
