## validation_dialog.gd
## Shows validation errors and warnings to the user
## Allows saving anyway if only warnings

extends Control

# Signals
signal cancelled()
signal save_anyway()

# Nodes
@onready var error_list: VBoxContainer = $Panel/VBoxContainer/ScrollContainer/ErrorList
@onready var warning_list: VBoxContainer = $Panel/VBoxContainer/ScrollContainer2/WarningList
@onready var cancel_button: Button = $Panel/VBoxContainer/ButtonContainer/CancelButton
@onready var save_anyway_button: Button = $Panel/VBoxContainer/ButtonContainer/SaveAnywayButton


func _ready() -> void:
	cancel_button.pressed.connect(_on_cancel)
	save_anyway_button.pressed.connect(_on_save_anyway)
	hide()


func show_errors(errors: Array[String], warnings: Array[String]) -> void:
	"""Show validation errors and warnings"""
	# Clear existing
	for child: Node in error_list.get_children():
		child.queue_free()
	for child: Node in warning_list.get_children():
		child.queue_free()
	
	# Add errors
	for error: String in errors:
		var label: Label = Label.new()
		label.text = "✗ " + error
		label.modulate = Color(1, 0.3, 0.3)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		error_list.add_child(label)
	
	# Add warnings
	for warning: String in warnings:
		var label: Label = Label.new()
		label.text = "⚠ " + warning
		label.modulate = Color(1, 1, 0.3)
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		warning_list.add_child(label)
	
	# Show/hide save anyway button based on errors
	save_anyway_button.visible = errors.is_empty()
	
	show()


func _on_cancel() -> void:
	"""Cancel button pressed"""
	AudioManager.play_click()
	hide()
	cancelled.emit()


func _on_save_anyway() -> void:
	"""Save anyway button pressed"""
	AudioManager.play_click()
	hide()
	save_anyway.emit()