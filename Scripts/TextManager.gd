extends Control

@onready var label = $Text
@onready var textEffectTimer = $TypewriterTimer
@onready var eventsTimer = $PanelTimer

var legendDialog := [
	"Tehdá se vyprávěl příběh,\nkterý si lidé dál šeptali.",
	"Byl to příběh národa.\nByl to příběh jednoty.",
	"Byl to příběh moudrosti.\nByl to příběh mystiky.",
	"Tento příběh nesl název \"Wise\nMystical Tale\".",
	"next panel",
	"Po tisíciletí, svět žil pod\nStromovcemi v míru.",
	"Pod Stromem by si všichni\nbyli rovni.",
	"next panel",
	"Ale kdyby se lid proti\nnim spikl..."	,
	"next panel",
	"Wilbur Poop by zakalil oblaka,",
	"Yapp Dollar by zničil trh",
	"a Smurf Cat by devastoval\nkrajinu.",
	"Nyní s hnijícími kořeny...",
	"by národ zažil jeho poslední\ndny.",
	"next panel",
	"Ale díky jejich víře...",
	"se tři Stromovci objevili\nna straně boha.",
	"next panel",
	"PRESIDENT NÁRODA",
	"VELITEL POLICIE",
	"A MOCNÝ BYZNYSMAN",
	"next panel",
	"Jen oni mohou zabránit\nStromovský pád",
	"a udržet národ v rovnováze.",
	"Jen poté může WMT znovu růst",
	"a svět by byl zachráněn od\nkrutosti Yapp Dollara.",
	"next panel",
	"Minulý týden, Trigware:\nstarosta Kořenova,",
	"navrhl mírnější trest pro\nSmurf Caty.",
	"Ti prohráli války, které začali\nkvůli jejich víře.",
	"Poté co tak řekl, byl obviněn\nz velezrady a ztratil jeho titul.",
	"A tak stabilita národu začíná ničit.",
	"end"
]

var currentCharacterIndex = 0
var currentPrintedTextIndex = -1

func _ready():
	textEffectTimer.timeout.connect(print_next_char)
	eventsTimer.timeout.connect(print_next_text)
	print_next_text()

func print_next_text():
	currentPrintedTextIndex += 1
	label.clear()
	currentCharacterIndex = 0
	eventsTimer.stop()
	var currentText = legendDialog[currentPrintedTextIndex]
	if currentText == "end":
		$Panels.transparency_tween(0, 0.5, false)
		return
	if currentText == "next panel":
		$Panels.transparency_tween(0, 0.5, true)
		return
	textEffectTimer.start()
	
func print_next_char():
	var writtenText = legendDialog[currentPrintedTextIndex]
	if currentCharacterIndex < writtenText.length():
		label.append_text(writtenText[currentCharacterIndex])
		currentCharacterIndex += 1
		return
	textEffectTimer.stop()
	eventsTimer.start()
	$Protagonists.show_hero_panel(currentPrintedTextIndex)
