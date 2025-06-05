extends Control

@onready var eventsTimer = $PanelTimer
@onready var skipNode = $"Skip Prompt"

var legendDialog := [
	Localization.get_text("legend_panel1_whisper"),
	Localization.get_text("legend_panel1_nation_unity"),
	Localization.get_text("legend_panel1_wise_mystical"),
	Localization.get_text("legend_panel1_wmtale"),
	"next panel",

	Localization.get_text("legend_panel2_peace"),
	Localization.get_text("legend_panel2_equality"),
	"next panel",
	
	Localization.get_text("legend_panel3_revolt"),
	"next panel",
	
	Localization.get_text("legend_panel4_wilbur"),
	Localization.get_text("legend_panel4_yapp"),
	Localization.get_text("legend_panel4_smurfcat"),
	Localization.get_text("legend_panel4_rotten"),
	Localization.get_text("legend_panel4_lastdays"),
	"next panel",
	
	Localization.get_text("legend_panel5_religion"),
	Localization.get_text("legend_panel5_god"),
	"next panel",
	
	Localization.get_text("legend_characters_rabbitek"),
	Localization.get_text("legend_characters_xdaforge"),
	Localization.get_text("legend_characters_gertofin"),
	"next panel",
	
	Localization.get_text("legend_panel6_treefall"),
	Localization.get_text("legend_panel6_balance"),
	Localization.get_text("legend_panel6_treegrow"),
	Localization.get_text("legend_panel6_yapp"),
	"next panel",
	
	Localization.get_text("legend_panel7_mayor"),
	Localization.get_text("legend_panel7_punishment"),
	Localization.get_text("legend_panel7_lost"),
	"next panel",
	
	Localization.get_text("legend_panel8_fired"),
	"end legend"
]

var currentCharacterIndex = 0
var currentPrintedTextIndex = -1
const lastTextBeforeBigPanel = 8

func _ready():
	TextSystem.fallbackPreset = TextSystem.Preset.LegendSmallPanel

	eventsTimer.timeout.connect(print_next_text)
	TextSystem.text_finished.connect(on_text_finished)
	print_next_text()

func print_next_text():
	currentPrintedTextIndex += 1
	eventsTimer.stop()
	var currentText = legendDialog[currentPrintedTextIndex]
	if currentText == "end legend":
		skipNode.end_cutscene()
		return
	if currentText == "next panel":
		$Panels.transparency_tween(0, 0.5, true)
		return
	TextSystem.print_preset(currentText)

func on_text_finished():
	if not (eventsTimer and eventsTimer.is_inside_tree()): return
	eventsTimer.start()
	$Protagonists.show_hero_panel(currentPrintedTextIndex)
	if currentPrintedTextIndex >= lastTextBeforeBigPanel:
		TextSystem.fallbackPreset = TextSystem.Preset.LegendBigPanel
