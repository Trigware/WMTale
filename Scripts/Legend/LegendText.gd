extends Control

@onready var label = $Text
@onready var eventsTimer = $PanelTimer

var legendDialog := [
	"Tehdá se vyprávěl příběh, " + char(0x200B) + "který si lidé dál šeptali.",
	"Byl to příběh národa.\nByl to příběh jednoty.",
	"Byl to příběh moudrosti.\nByl to příběh mystiky.",
	"Tento příběh nesl název \"Wise Mystical Tale\".",
	"next panel",
	"Po tisíciletí, svět žil pod Stromovcemi v míru.",
	"Pod Stromem by si všichni byli rovni.",
	"next panel",
	"Ale kdyby se lid proti nim spikl..."	,
	"next panel",
	"Wilbur Poop by zakalil oblaka,",
	"Yapp Dollar by zničil trh",
	"a Smurf Cat by devastoval krajinu.",
	"Nyní s hnijícími kořeny...",
	"by národ zažil jeho poslední dny.",
	"next panel",
	"Ale díky jejich víře...",
	"se tři Stromovci objevili na straně boha.",
	"next panel",
	"JEDEN CHTĚL BÝT POLITIK",
	"DRUHÝ ZAS POLICISTA",
	"A TŘETÍ CHCĚL BÝT PROSTĚ BOHATEJ",
	"next panel",
	"Jen oni mohou zabránit Stromovský pád",
	"a udržet národ v rovnováze.",
	"Jen poté může WMT znovu růst",
	"a svět může být zachráněn od krutosti Yapp Dollara.",
	"next panel",
	"Minulý týden, Trigware: starosta Kořenova,",
	"navrhl mírnější trest pro Smurf Caty.",
	"Ti prohráli války, které začali kvůli jejich víře.",
	"next panel",
	"Poté co tak řekl, byl obviněn z velezrady a ztratil jeho titul.",
	"A tak se stabilita národa začíná ničit.",
	"end legend"
]

var currentCharacterIndex = 0
var currentPrintedTextIndex = -1
var currentPreset: TextSystem.Preset = TextSystem.Preset.LegendSmallPanel
const lastTextBeforeBigPanel = 8

func _ready():
	eventsTimer.timeout.connect(print_next_text)
	TextSystem.text_finished.connect(on_text_finished)
	print_next_text()

func print_next_text():
	currentPrintedTextIndex += 1
	eventsTimer.stop()
	var currentText = legendDialog[currentPrintedTextIndex]
	if currentText == "end legend":
		$Panels.transparency_tween(0, 0.5, false)
		return
	if currentText == "next panel":
		$Panels.transparency_tween(0, 0.5, true)
		return
	TextSystem.print_preset(currentText, currentPreset)
	
func print_next_char():
	var writtenText = legendDialog[currentPrintedTextIndex]
	if currentCharacterIndex < writtenText.length():
		label.append_text(writtenText[currentCharacterIndex])
		currentCharacterIndex += 1
		return

func on_text_finished():
	eventsTimer.start()
	$Protagonists.show_hero_panel(currentPrintedTextIndex)
	if currentPrintedTextIndex >= lastTextBeforeBigPanel:
		currentPreset = TextSystem.Preset.LegendBigPanel
