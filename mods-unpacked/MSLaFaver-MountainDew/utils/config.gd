extends Control

@export var help_toggle: CheckButton

const id = "MSLaFaver-MountainDew"
const id_modmenu = "MSLaFaver-ModMenu"

var speaker_press: AudioStreamPlayer2D

func _ready():
	help_toggle.button_pressed = ModLoader.get_node(id).god_help_us_all
	help_toggle.toggled.connect(_on_toggled_help)
	
	speaker_press = get_node("/root/menu/speaker_press")
	
	var toggle_off_image = Image.load_from_file("res://mods-unpacked/%s/assets/toggle-off.png" % id_modmenu)
	var toggle_off_texture = ImageTexture.create_from_image(toggle_off_image)
	var toggle_on_image = Image.load_from_file("res://mods-unpacked/%s/assets/toggle-on.png" % id_modmenu)
	var toggle_on_texture = ImageTexture.create_from_image(toggle_on_image)
	
	for toggle in [help_toggle]:
		toggle.add_theme_icon_override("unchecked", toggle_off_texture)
		toggle.add_theme_icon_override("unchecked_disabled", toggle_off_texture)
		toggle.add_theme_icon_override("checked", toggle_on_texture)
		toggle.add_theme_icon_override("checked_disabled", toggle_on_texture)
	
func _on_toggled_help(enabled: bool):
	ModLoader.get_node(id).god_help_us_all = enabled
	speaker_press.play()
