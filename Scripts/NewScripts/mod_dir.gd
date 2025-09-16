extends Node

class_name ModsDir

const GAME_NAME := "WhichWitch";
const MODS_FOLDER := "Mods";

static func get_mods_dir() -> String:
	var base_path = ""
	
	match OS.get_name():
		"Windows":
			base_path = OS.get_system_dir(OS.SYSTEM_DIR_DOCUMENTS);
		_:
			base_path = ProjectSettings.globalize_path("user://");
			
	var mods_dir = base_path.path_join(GAME_NAME).path_join(MODS_FOLDER);
	
	DirAccess.make_dir_recursive_absolute(mods_dir);
	
	return mods_dir;

static func open_mods_dir() -> void:
	var path = get_mods_dir();
	match OS.get_name():
		"Windows":
			OS.shell_open(path);
		_:
			push_warning("Unsupported OS for opening Mods folder: %s" % OS.get_name());
