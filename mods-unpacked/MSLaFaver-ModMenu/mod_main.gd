extends Node

const hooks = [
	"scripts/BurnerPhone.gd",
	"scripts/ButtonClass.gd",
	"scripts/MenuManager.gd",
	"scripts/OptionsManager.gd",
	"scripts/SignatureManager.gd",
	"scripts/StatueManager.gd"
]

const id = "MSLaFaver-ModMenu"
var config_defaults = {
	"check_for_updates": true,
	"remove_filter": false,
	"remove_discord": true,
	"burner_fix": false,
	"old_pills": false
}

# Set this to true from your config if you have text fields.
var suppress_return = false

# This mod skips chain.execute_next_async() for the burner phone if its fix is
# enabled. Set self.burner_override = true to always chain the original function.
var burner_override = false

var lerp_flag = false
var fixed_image = false
var initialized = false
var button_class_array = []

func _init():
	ModLoaderStore.ml_options.semantic_version = GlobalVariables.currentVersion_nr.substr(1)
	
	for hook in hooks:
		ModLoaderMod.install_script_hooks("res://%s" % hook,
			"res://mods-unpacked/%s/%s" % [id, hook])
	
func _ready():
	GlobalVariables.currentVersion = "%s.%s%s / BRML Neo v%s.%s.%s" % [
		GlobalVariables.currentVersion_nr,
		GlobalVariables.currentVersion_hotfix,
		GlobalVariables.versuffix_steam if GlobalVariables.using_steam else GlobalVariables.versuffix_itch,
		ProjectSettings.get_setting("brml/version/major"),
		ProjectSettings.get_setting("brml/version/minor"),
		ProjectSettings.get_setting("brml/version/patch")
	]
	
	config_init(id, config_defaults)
	
	do_translations()

# Use this function to initialize your mod config with defaults.
func config_init(id: String, config_defaults: Dictionary):
	if not ModLoaderConfig.has_config(id, "user"):
		ModLoaderConfig.create_config(id, "user", config_defaults)
	else:
		var mod_config = ModLoaderConfig.get_config(id, "user")
		var updated = false
		for key in config_defaults.keys():
			if not mod_config.data.has(key):
				mod_config.data[key] = config_defaults.get(key)
				updated = true
		if updated:
			ModLoaderConfig.update_config(mod_config)

func _process(_delta):
	for button in button_class_array:
		if button != null:
			const text_scale = 0.76
			var size_original = button.ui.size.x
			button.ui.size.x = 0
			var size = button.ui.size.x * text_scale
			button.ui.size.x = size_original
			var parent = button.get_parent()
			parent.position = Vector2(button.ui.position.x + size_original / 2.0 - size / 2.0, button.ui.position.y + 8)
			parent.size = Vector2(size, 23)
	
	var root = get_node("/root")
	var camera = root.find_children("Camera", "MouseRaycast", true, false)
	if camera != null and not camera.is_empty():
		var rect = camera.front().get_node("post processing/posterization test/BackBufferCopy/ColorRect")
		if rect != null:
			rect.position = Vector2(-100,-100)
	var children = root.get_children()
	if not children.is_empty():
		match children.back().name:
			"menu":
				if not fixed_image:
					var config = ModLoaderConfig.get_config(id, "user")
					if config != null:
						var data = config.data
						if data.get("remove_filter"):
							var viewblocker_parent = root.get_node("menu/Camera/dialogue UI/viewblocker parent")
							var ratchet = viewblocker_parent.get_node("ratchet")
							var splash = TextureRect.new()
							var texture = ImageTexture.create_from_image(Image.load_from_file("res://mods-unpacked/%s/assets/splash.jpg" % id))
							splash.texture = texture
							splash.position = Vector2(806,389)
							splash.scale = Vector2(0.246,0.246)
							ratchet.add_child(splash)
					fixed_image = true
			"main":
				var manager = root.get_node("main/standalone managers/round manager")
				if (manager.ui_doubleornothing.visible and not lerp_flag):
					manager.lerpingscore = false
					lerp_flag = true
				elif (not manager.ui_doubleornothing.visible and lerp_flag):
					lerp_flag = false
				fixed_image = false
			_:
				fixed_image = false

func do_translations():
	# Buckshot treats native translations as OptimizedTranslation objects
	# and they cannot be edited. So we remove them and reload the original CSVs.
	for locale in TranslationServer.get_loaded_locales():
		var translation = TranslationServer.get_translation_object(locale)
		TranslationServer.remove_translation(translation)
	
	var base_path
	if not GlobalVariables.using_steam:
		base_path = "res://localization/Buckshot Roulette - Localization Sheet - Sheet47.csv"
	else:
		base_path = "res://multiplayer/mp_localization/Buckshot Roulette - Localization Sheet - multiplayer24.csv"
	
	import_translation(base_path)
	find_csv_files("res://translations")
	
	var mod_data_set = ModLoaderMod.get_mod_data_all().values()
	for mod_data in mod_data_set:
		var mod_name = mod_data.manifest.name
		var mod_namespace = mod_data.manifest.mod_namespace
		var full_name = "%s-%s" % [mod_namespace, mod_name]
		var translations_dir = "res://mods-unpacked/%s/translations" % full_name
		if DirAccess.dir_exists_absolute(translations_dir):
			find_csv_files(translations_dir)

func import_translation(path: String):
	var sheet = FileAccess.open(path, FileAccess.READ)
	var header = Array(sheet.get_csv_line())
	if header.pop_front() == "key":
		var translations = []
		for locale in header:
			if not locale.strip_edges().is_empty():
				var translation = TranslationServer.get_translation_object(locale)
				if translation == null:
					translation = Translation.new()
					translation.locale = locale
				translations.append(translation)
		
		while not sheet.eof_reached():
			var line = Array(sheet.get_csv_line())
			var key = line.pop_front()
			key = fix_key(key)
			if not key.strip_edges().is_empty():
				for i in range(line.size()):
					if i < translations.size() and translations[i] is Translation:
						if not line[i].strip_edges().is_empty():
							translations[i].erase_message(key)
							translations[i].add_message(key, line[i])
		
		for translation in translations:
			if translation is Translation:
				TranslationServer.add_translation(translation)

func fix_key(key: String):
	if not key.strip_edges().is_empty():
		if key.begins_with("<!MissingKey:"):
			match key:
				"<!MissingKey:15:WORLDWIDE>": key = "MP_RANGE WORLDWIDE"
				"<!MissingKey:56:NEAR>": key = "MP_RANGE NEAR"
				"<!MissingKey:78:FAR>": key = "MP_RANGE FAR"
				_: key = ""
	return key

func find_csv_files(dir):
	for csv in  Array(DirAccess.get_files_at(dir)):
		if csv.ends_with(".csv"):
			import_translation("%s/%s" % [dir, csv])
