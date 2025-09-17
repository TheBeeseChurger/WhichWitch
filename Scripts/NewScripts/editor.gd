extends Control

## The FileDialog node for opening audio files
@onready var file_dialog : FileDialog = $FileDialog;

## The audio stream holding the audio currently being edited
static var stream;

func _ready() -> void:
	_init_file_dialog();

## Initialize the file dialog prompt for choosing audio file
func _init_file_dialog() -> void:
	file_dialog.access = FileDialog.ACCESS_FILESYSTEM;
	file_dialog.file_mode = FileDialog.FILE_MODE_OPEN_FILE;
	file_dialog.filters = PackedStringArray(["*.wav ; WAV Audio", "*.ogg ; OGG Vorbis", "*.mp3 ; MP3 Audio"]);
	
	file_dialog.file_selected.connect(_file_select);
	

## Button function for opening audio file dialog prompt
func _on_import_pressed() -> void:
	file_dialog.popup_centered();

## Return function for file dialog prompt
## 
## Uses [param path] to find the audio file's location on disk
func _file_select(path: String) -> void:
	print("The audio file path: ", path);
	var ext = path.get_extension().to_lower();
	
	match ext:
		"wav":
			var audio = AudioStreamWAV.load_from_file(path);
			if audio:
				stream = audio;
			else:
				print("Invalid WAV file at \"%s\"", path);
		"ogg":
			var audio = AudioStreamOggVorbis.load_from_file(path);
			if audio:
				stream = audio;
			else:
				print("Invalid Ogg Vorbis file at \"%s\"", path);
		"mp3":
			var audio = AudioStreamMP3.load_from_file(path);
			if audio:
				stream = audio;
			else:
				print("Invalid MP3 file at \"%s\"", path);
		_:
			print("Unsupported file type as \"%s\"", path);
