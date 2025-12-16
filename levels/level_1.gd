extends Stage

# Chỉ giữ lại những gì đặc thù của Level 1
const OPENING_CUTSCENE = preload("res://dialog/cutscenes/opening_cutscene.tscn")

func _ready():
	# Override hàm _ready của cha.
	# Thay vì gọi super._ready() ngay, ta chạy cutscene trước.
	play_opening_cutscene()

func play_opening_cutscene():
	var cutscene = OPENING_CUTSCENE.instantiate()
	
	var canvas_layer = CanvasLayer.new()
	canvas_layer.layer = 0 # Hoặc cao hơn nếu muốn che HUD
	add_child(canvas_layer)
	canvas_layer.add_child(cutscene)
	
	cutscene.cutscene_finished.connect(func():
		canvas_layer.queue_free()
		start_level_logic()
	)

func start_level_logic():
	# Sau khi cutscene xong, mới gọi hàm khởi tạo của Stage cha
	# Hàm cha sẽ tự động chạy run_start_timeline() vì ta đã config trong Inspector
	super._ready()

# Chúng ta KHÔNG cần _exit_tree hay trigger_ambient_dialogue ở đây nữa 
# vì Stage đã lo hết rồi.
