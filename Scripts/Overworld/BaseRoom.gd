extends Node2D

@export var cutscene := CutsceneManager.Cutscene.None
@export var cutscenePosition := Vector2()
@export var roomEnterances : Dictionary[Overworld.Room, EnteranceData]
@export var roomMusic := ""
@export var roomMusicPitchRange := 0.1
@export var playNoMusic := false
