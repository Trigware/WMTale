extends CharacterBody2D

var diagonal_path_direction : Vector2
var remainder_path_direction : Vector2

var diagonal_path_position : Vector2
var current_target : Vector2
var final_look_dir := Vector2.ZERO
var speed := Player.player_speed

var controlled_body = Player.node
var agent_type = MovingNPC.AgentType.Uninitialized
var stringAnimation : String

var currently_moving = false
var agent_variation := ""
var party_member_index : int

@onready var sprite = $Sprite
@onready var collider = $Collider

func _ready():
	if agent_type == MovingNPC.AgentType.Uninitialized:
		push_error("Uninitialized agent type for a moving NPC!")
		queue_free()
		return
	global_position = Player.get_body_pos()
	name = get_appropriate_name()
	if agent_type != MovingNPC.AgentType.PlayerAgent:
		setup_moving_npc()

func setup_moving_npc():
	sprite.sprite_frames = UID.SPF_MOVING_NPC[agent_type]
	set_animation(Player.node.stringAnimation)
	
	controlled_body = self
	if agent_type == MovingNPC.AgentType.FollowerAgent:
		party_member_index = Overworld.party_members.find(agent_variation)

func set_animation(dir):
	sprite.animation = agent_variation + "Walk" + dir

func get_appropriate_name():
	var agent_type_name = MovingNPC.get_agent_type_name(agent_type)
	if agent_variation == "": return agent_type_name
	return agent_variation + " (" + agent_type_name + ")"

func move_by(x_offset, y_offset):
	await move_to_target(controlled_body.global_position + Vector2(x_offset, y_offset) * Overworld.scaleConst)

func move_to(x, y):
	await move_to_target(Vector2(x, y) * Overworld.scaleConst)

func move_to_target(target: Vector2):
	if currently_moving: return
	currently_moving = true
	current_target = target
	get_diagonal_path_info()
	await move_to_point(diagonal_path_position, diagonal_path_direction)
	await move_to_point(current_target, remainder_path_direction)
	set_direction_animation()
	currently_moving = false

func move_to_point(point: Vector2, dir: Vector2):
	if dir == Vector2.ZERO: return
	var previous_distance_to_point = INF
	controlled_body.stringAnimation = get_string_direction(dir)
	while true:
		var current_position = controlled_body.global_position
		var distance_to_point = point.distance_to(current_position)
		if distance_to_point < 1 or distance_to_point >= previous_distance_to_point: return
		var hit_wall = controlled_body.take_step(dir, speed)
		if hit_wall: return
		previous_distance_to_point = distance_to_point
		await get_tree().process_frame

func set_direction_animation():
	if final_look_dir == Vector2.ZERO: return
	controlled_body.stringAnimation = get_string_direction(final_look_dir)
	controlled_body.update_walk_animation_frame()

func get_string_direction(dir: Vector2):
	if dir == Vector2.ZERO: return ""
	if dir.x != 0: return "Left" if dir.x < 0 else "Right"
	return "Up" if dir.y < 0 else "Down"

func get_diagonal_path_info():
	var current_position = controlled_body.global_position
	var delta = current_target - current_position
	var local_diagonal_path = get_dialogal_path(delta)
	diagonal_path_direction = get_movement_direction(local_diagonal_path).normalized()
	diagonal_path_position = current_position + local_diagonal_path
	var remainder_distance = current_target - diagonal_path_position
	remainder_path_direction = get_movement_direction(remainder_distance)

func get_dialogal_path(delta: Vector2):
	var smallest_value = min(abs(delta.x), abs(delta.y))
	return Vector2(sign(delta.x) * smallest_value, sign(delta.y) * smallest_value)

func get_movement_direction(vec: Vector2):
	return Vector2(sign(vec.x), sign(vec.y))
	
func take_step_towards_player(target):
	global_position = target
	print(target)
