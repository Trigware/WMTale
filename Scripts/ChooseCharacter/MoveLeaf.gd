extends TextureRect

@onready var sceneRoot = get_node("/root/ChooseCharacter")
const speed = 200
const collisionPoints = Vector2(1090, 583)
var RabbitekZone := Rect2(Vector2(485, 50), Vector2(120, 225))
var XDaForgeZone := Rect2(Vector2(640, 50), Vector2(120, 225))
var GertofinZone := Rect2(Vector2(820, 70), Vector2(110, 195))

var currentChoice := TriggerZone.None
enum TriggerZone {
	None,
	Rabbitek,
	xDaForge,
	Gertofin
}

signal leaf_moved
signal leaf_entered_character_trigger

func _physics_process(delta: float):
	if not sceneRoot.leafMovementAllowed: return
	move_leaf(delta)

func move_leaf(delta):
	var direction = Vector2.ZERO
	if Input.is_action_pressed("move_right") and position.x < collisionPoints.x:
		direction.x += 1
	if Input.is_action_pressed("move_left") and position.x > 0:
		direction.x -= 1
	if Input.is_action_pressed("move_down") and position.y < collisionPoints.y:
		direction.y += 1
	if Input.is_action_pressed("move_up") and position.y > 0:
		direction.y -= 1

	if direction != Vector2.ZERO: 
		emit_signal("leaf_moved")
	var finalDirection = direction.normalized() * speed * delta
	if Input.is_action_pressed("move_fast"):
		finalDirection *= 2
	position += finalDirection
	update_current_zone()

func update_current_zone():
	if not Input.is_action_just_pressed("character_select"): return
	currentChoice = TriggerZone.None
	if RabbitekZone.has_point(position): currentChoice = TriggerZone.Rabbitek
	if XDaForgeZone.has_point(position): currentChoice = TriggerZone.xDaForge
	if GertofinZone.has_point(position): currentChoice = TriggerZone.Gertofin
	if currentChoice != TriggerZone.None:
		emit_signal("leaf_entered_character_trigger") 
