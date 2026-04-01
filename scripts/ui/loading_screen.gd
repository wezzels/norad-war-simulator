## loading_screen.gd
## Loading screen shown during scene transitions
## Displays progress, tips, and version info

extends Control

# Nodes
@onready var status_label: Label = $VBoxContainer/Status
@onready var progress_bar: ProgressBar = $VBoxContainer/ProgressBar
@onready var tip_label: Label = $VBoxContainer/Tip
@onready var version_label: Label = $Version
@onready var title_label: Label = $VBoxContainer/Title
@onready var background: ColorRect = $Background

# Tips to display
const TIPS: Array[String] = [
	"Tip: Use number keys 1-9 to set simulation speed",
	"Tip: GBI interceptors work best in midcourse phase",
	"Tip: THAAD is effective against short-range missiles",
	"Tip: Monitor DEFCON levels to track threat escalation",
	"Tip: Satellites provide early warning of launches",
	"Tip: The shoot-look-shoot doctrine saves interceptors",
	"Tip: Press Space to launch a test missile in debug mode",
	"Tip: Mouse drag to orbit the camera around the globe",
	"Tip: Scroll wheel zooms in and out",
	"Tip: Complete scenarios to unlock technology upgrades",
	"Tip: Campaign mode unlocks new interceptor types",
	"Tip: Higher difficulty scenarios award more tech points"
]

# State
var progress: float = 0.0
var target_progress: float = 100.0

# Animation
const FADE_DURATION: float = 0.3


func _ready() -> void:
	# Show random tip
	tip_label.text = TIPS[randi() % TIPS.size()]
	
	# Set version
	version_label.text = "v0.5.0-alpha"
	
	# Start at 0
	progress_bar.value = 0.0
	
	# Animate in
	_animate_in()


func _animate_in() -> void:
	"""Fade in animation"""
	modulate.a = 0.0
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 1.0, FADE_DURATION)


func set_status(text: String) -> void:
	"""Update loading status"""
	status_label.text = text


func set_progress(value: float) -> void:
	"""Set progress bar value"""
	progress_bar.value = value


func animate_progress(duration: float = 1.0) -> void:
	"""Animate progress bar"""
	var tween: Tween = create_tween()
	tween.tween_property(progress_bar, "value", target_progress, duration)
	await tween.finished


func complete() -> void:
	"""Set progress to complete"""
	progress_bar.value = 100.0
	status_label.text = "Ready!"


func animate_out() -> void:
	"""Fade out animation"""
	var tween: Tween = create_tween()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(self, "modulate:a", 0.0, FADE_DURATION)
	await tween.finished


func simulate_loading(steps: int = 5, delay: float = 0.2) -> void:
	"""Simulate loading with steps"""
	for i: int in range(steps):
		set_status("Loading... (%d/%d)" % [i + 1, steps])
		set_progress((float(i + 1) / float(steps)) * 100.0)
		await get_tree().create_timer(delay).timeout
	
	complete()
	await get_tree().create_timer(0.5).timeout