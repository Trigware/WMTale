extends Sprite2D

@export var beehive_type := BeehiveType.Yellow
@onready var audioArea = $"Audio Area"
var npcID := NPCData.ID.BeehiveRegular_SAVEINTROROOM

enum BeehiveType {
	Yellow,
	Green,
	Blue
}

func _ready():
	frame_coords.x = beehive_type
	if beehive_type == BeehiveType.Blue: npcID = NPCData.ID.BlueBeehive_SAVEINTROROOM
	else: audioArea.queue_free()
