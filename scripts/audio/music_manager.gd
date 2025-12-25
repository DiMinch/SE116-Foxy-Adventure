extends Node

var music_player: AudioStreamPlayer = null

var target_volume_db: float = 0.0
var fade_duration: float = 1.0 

var is_music_looping: bool = true

func _ready():
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	add_child(music_player)
	target_volume_db = music_player.volume_db
	process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.finished.connect(_on_music_finished)

func _process(delta):
	if music_player and music_player.volume_db != target_volume_db:
		var current_db = music_player.volume_db
		var new_db = lerp(current_db, target_volume_db, delta / fade_duration)
		music_player.volume_db = new_db
		
func play_music(new_music: AudioStream, loop: bool = true, volume: float = 0.0, fade: float = 1.0) -> void:
	if music_player == null:
		return

	if music_player.stream == new_music and music_player.playing:
		target_volume_db = volume
		return
		
	is_music_looping = loop
	
	music_player.stream = new_music
	music_player.volume_db = -80.0
	target_volume_db = volume
	fade_duration = fade
	
	music_player.play()

func stop_music(fade_out_time: float = 1.0) -> void:
	if music_player == null or not music_player.playing:
		return
		
	target_volume_db = -80.0
	fade_duration = fade_out_time

	await get_tree().create_timer(fade_duration).timeout
	if music_player and music_player.playing:
		music_player.stop()

func transition_music(new_music: AudioStream, volume: float = 0.0, fade_out: float = 0.5, fade_in: float = 1.0) -> void:
	if music_player and music_player.playing:
		stop_music(fade_out)
		
	await get_tree().create_timer(fade_out).timeout 
	play_music(new_music, true, volume, fade_in)
	
func _on_music_finished():
	if is_music_looping:
		music_player.play()
