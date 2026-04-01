## button_animations.gd
## Button hover/press animations
## Apply to buttons for polish

extends Resource

class_name ButtonAnimations

# Animation settings
const HOVER_SCALE: float = 1.05
const PRESS_SCALE: float = 0.95
const ANIMATION_DURATION: float = 0.1
const HOVER_BRIGHTNESS: float = 1.2
const PRESS_BRIGHTNESS: float = 0.8


static func setup_button(button: Button) -> void:
	"""Setup hover and press animations for a button"""
	# Connect signals if not already connected
	if not button.mouse_entered.is_connected(_on_hover.bind(button)):
		button.mouse_entered.connect(_on_hover.bind(button))
	
	if not button.mouse_exited.is_connected(_on_unhover.bind(button)):
		button.mouse_exited.connect(_on_unhover.bind(button))
	
	if not button.button_down.is_connected(_on_press.bind(button)):
		button.button_down.connect(_on_press.bind(button))
	
	if not button.button_up.is_connected(_on_release.bind(button)):
		button.button_up.connect(_on_release.bind(button))
	
	# Store original properties
	button.set_meta("original_scale", button.scale)
	button.set_meta("original_modulate", button.modulate)


static func _on_hover(button: Button) -> void:
	"""Handle hover animation"""
	if not button.has_meta("original_scale"):
		return
	
	var tween: Tween = button.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Scale up slightly
	tween.tween_property(button, "scale", 
		button.get_meta("original_scale") * HOVER_SCALE, 
		ANIMATION_DURATION)
	
	# Brighten
	var bright_color: Color = button.get_meta("original_modulate") * HOVER_BRIGHTNESS
	bright_color.a = 1.0
	tween.parallel().tween_property(button, "modulate", bright_color, ANIMATION_DURATION)
	
	# Play hover sound
	AudioManager.play_hover()


static func _on_unhover(button: Button) -> void:
	"""Handle unhover animation"""
	if not button.has_meta("original_scale"):
		return
	
	var tween: Tween = button.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Return to original scale
	tween.tween_property(button, "scale", 
		button.get_meta("original_scale"), 
		ANIMATION_DURATION)
	
	# Return to original color
	tween.parallel().tween_property(button, "modulate", 
		button.get_meta("original_modulate"), 
		ANIMATION_DURATION)


static func _on_press(button: Button) -> void:
	"""Handle press animation"""
	if not button.has_meta("original_scale"):
		return
	
	var tween: Tween = button.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Scale down
	tween.tween_property(button, "scale", 
		button.get_meta("original_scale") * PRESS_SCALE, 
		ANIMATION_DURATION * 0.5)
	
	# Darken
	var dark_color: Color = button.get_meta("original_modulate") * PRESS_BRIGHTNESS
	dark_color.a = 1.0
	tween.parallel().tween_property(button, "modulate", dark_color, ANIMATION_DURATION * 0.5)


static func _on_release(button: Button) -> void:
	"""Handle release animation - return to hover state"""
	if not button.has_meta("original_scale"):
		return
	
	var tween: Tween = button.create_tween()
	tween.set_ease(Tween.EASE_OUT)
	tween.set_trans(Tween.TRANS_CUBIC)
	
	# Return to hover scale
	tween.tween_property(button, "scale", 
		button.get_meta("original_scale") * HOVER_SCALE, 
		ANIMATION_DURATION)
	
	# Return to hover color
	var bright_color: Color = button.get_meta("original_modulate") * HOVER_BRIGHTNESS
	bright_color.a = 1.0
	tween.parallel().tween_property(button, "modulate", bright_color, ANIMATION_DURATION)


static func setup_all_buttons(node: Node) -> void:
	"""Setup animations for all buttons in a node tree"""
	for child: Node in node.get_children():
		if child is Button:
			setup_button(child)
		# Recursively check children
		setup_all_buttons(child)