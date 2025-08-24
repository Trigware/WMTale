extends Node

const SFX_LIGHT_SWITCH := preload("uid://dwd8f0supxsjy")
const SFX_RELIGIOUS_SPAWN := preload("uid://bxbaxl1ywsjkv")
const SFX_STATUS_EFFECT := preload("uid://d2p80u5vf15em")
const SFX_SHALLOW_WATER_SPLASH := preload("uid://cvm38aljsoa55")
const SFX_DEEP_WATER_SPLASH := preload("uid://b3p620csvwmov")
const SFX_LEAF_MODE_ENTER = preload("uid://b7fftayvh5ay5")
const SFX_FILE_SELECT_COPY = SFX_LEAF_MODE_ENTER
const SFX_LEAF_APPEAR := SFX_LEAF_MODE_ENTER
const SFX_MENU_CANCEL = preload("uid://bw4i3h1xntksn")
const SFX_CONFIRM_CHOICE = SFX_MENU_CANCEL
const SFX_GET_UP := SFX_MENU_CANCEL
const SFX_PLAYER_HIT := SFX_MENU_CANCEL
const SFX_SIT := preload("uid://we2j25k6lspy")
const SFX_PRAYING := preload("uid://d22ia3bcj5w51")
const SFX_PLAYER_HEAL := preload("uid://cdcvjc15gqrbu")
const SFX_MENU_CHANGED_CHOICE := preload("uid://cufhe7c7ppn6k")
const SFX_ITEM_OBTAINED := preload("uid://bkbyp23xibt1j")
const SFX_GAME_SAVED := preload("uid://dil44htde8yhn")
const SFX_SUMMON_CHARACTERS := preload("uid://7s1nepdr4lmj")
const SFX_FILE_SELECT_DELETE_FILE := SFX_SUMMON_CHARACTERS
const SFX_LEAF_BREAK := preload("uid://ji0wtisd2jwh")
const SFX_BIBLE_BALL_APPEARS := preload("uid://cntva0ygm8pfl")
const SFX_LILYPAD_DISAPPEAR := preload("uid://ditkvdbpa3d5t")
const SFX_EXPLOSION := preload("uid://biy5kk5vnsyw1")
const SFX_MUSHROOM_PETRIFY := preload("uid://c3ot5d7e3um0h")
const SFX_START_GAME := SFX_MUSHROOM_PETRIFY
const SFX_ANTIDOTE_MUSHROOM := preload("uid://do1t2ow1doy85")
const SFX_CAMPFIRE := preload("uid://bpp7qnbmhttta")
const SFX_NAIL_SWING := preload("uid://bhkg7d1r5ia7u")
const SFX_SWOOSH := preload("uid://xdjk8e08glhe")
const SFX_MUSHROOM_FALL := preload("uid://dxckvwhbveeeu")
const SFX_CROWBAR := preload("uid://mbxu5hjhv3td")
const SFX_MAGNET := preload("uid://brdb7aweelctt")
const SFX_ROCKS_FALL := preload("uid://dbadvl1vii5qp")
const SFX_DNA_APPEAR := preload("uid://c1hbcnlwv8svd")
const SFX_MAIN_MENU_CHOICE_CHANGE := preload("uid://3taqr51tfc0y")

const MSC_SELF_PROCLAIMED_QUEEN = preload("uid://diiie2j47xlta")

enum Footstep {
	Ground,
	Leaves,
	Water
}

const SFX_FOOTSTEPS : Dictionary[Footstep, AudioStream] = {
	Footstep.Ground: preload("uid://b80mrqlatnno7"),
	Footstep.Leaves: preload("uid://bkoaav88d7kh0"),
	Footstep.Water: preload("uid://ddcut38r6p3hw")
}

const TALK_DEFAULT := preload("uid://bvj0uglmngfj1")
const TALK_WMT := preload("uid://segl4jq4bf86")

const SCN_OVERWORLD := preload("uid://c8vj3cwoy76i1")
const SCN_STATUS_EFFECT := preload("uid://bvmbuvmx0rdtg")
const SCN_CHOOSE_LANGUAGE := preload("uid://dhpqwrhqq3yr2")
const SCN_LEGEND := preload("uid://byncuir8hto51")
const SCN_FILE_SELECT := preload("uid://rv76lp5lfepw")
const SCN_CHOOSE_CHARACTER := preload("uid://3f2iijurxqrx")
const SCN_EMPTY := preload("uid://ddfqlsytkci3n")
const SCN_ERROR_HANDLELER := preload("uid://i83bvbps8fab")
const SCN_GAME_OVER := preload("uid://ct1j1mlh01gam")
const SCN_HEALTH_CHANGE_INFO := preload("uid://bidy22336eykw")
const SCN_EXPLOSION := preload("uid://yaji2aem6v4")
const SCN_MOVINGNPC := preload("uid://cpc5fcj5uokxi")
const SCN_LANGUAGE_LABEL := preload("uid://liebhejx35kc")
const SCN_FILE_INFO := preload("uid://crnbdskhtichk")

const SCN_LILYPAD_MECHANIC : Dictionary[Overworld.Room, PackedScene] = {
	Overworld.Room.Weird_LilypadRoom: preload("uid://do8xa234u6nyw")
}

enum LILYPAD_FLOWER_DIRECTION {
	UP,
	DOWN
}

const IMG_LILYPAD_FLOWER : Dictionary[LILYPAD_FLOWER_DIRECTION, Texture2D] = {
	LILYPAD_FLOWER_DIRECTION.UP: preload("uid://c7nu051xmsosg"),
	LILYPAD_FLOWER_DIRECTION.DOWN: preload("uid://bb3sfufat5yx3")
}

enum LeafModeCharacters {
	RABBITEK,
	XDAFORGE,
	GERTOFIN
}

enum ValidLanguages {
	ENGLISH,
	CZECH
}

const IMG_UIHEAD : Dictionary[LeafModeCharacters, Texture2D] = {
	LeafModeCharacters.RABBITEK: preload("uid://dh75e7r82npc"),
	LeafModeCharacters.XDAFORGE: preload("uid://dh07hbvqh1puq"),
	LeafModeCharacters.GERTOFIN: preload("uid://c36dpe0rkmu81")
}

const IMG_FLAG : Dictionary[ValidLanguages, Texture2D] = {
	ValidLanguages.ENGLISH: preload("uid://dwnitaljbw2ll"),
	ValidLanguages.CZECH: preload("uid://ds6vhe1ppfh5q")
}

const IMG_LEAF := preload("uid://d0fymc1ye236d")
const IMG_NOLEAF_SELECTOR := preload("uid://cfysxnymr7w2t")

const IMG_MAIN_MENU_BG := preload("uid://dyw06wm2nnvr1")

const IMG_CHAPTER_BACKGROUNDS : Dictionary[Enum.Chapter, Texture2D] = {
	Enum.Chapter.WeirdForest: preload("uid://edxrqj6gbhia"),
	Enum.Chapter.BaseOfOperations: preload("uid://edxrqj6gbhia"),
	Enum.Chapter.Uprising: preload("uid://edxrqj6gbhia")
}

func get_ui_head_with_string(head: String):
	return get_enum_member_with_string(head, LeafModeCharacters, IMG_UIHEAD)

func get_flag_with_string(lang: String):
	return get_enum_member_with_string(lang, ValidLanguages, IMG_FLAG)

func get_enum_member_with_string(text: String, enumerable: Dictionary, resource_map: Dictionary):
	var upper_case_str = text.to_upper()
	if not upper_case_str in enumerable: return null
	var enum_member = enumerable[upper_case_str]
	return resource_map[enum_member]

const SPF_MOVING_NPCS : Dictionary[Enum.AgentVariation, SpriteFrames] = {
	Enum.AgentVariation.xdaforge: preload("uid://b77va3m0sleuv"),
	Enum.AgentVariation.rabbitek: preload("uid://cxvdww3fec3uh"),
	Enum.AgentVariation.gertofin: preload("uid://caot3n3mxcshk"),
	Enum.AgentVariation.Nixie: preload("uid://b785s2t3fewxf")
}

const CLD_PLAYER := preload("uid://bj0u242dgcot1")

func get_agent_collider_info(agent_variation: Enum.AgentVariation) -> Dictionary:
	var agent_variation_str = MovingNPC.get_agent_variation_as_str(agent_variation)
	if agent_variation_str in Player.playableCharacters:
		return {"collider": CLD_PLAYER, "position": Vector2(0, 16)}
	return {}

const SHD_HIDE_SPRITE := preload("uid://dqmk2fcx6j66e")
