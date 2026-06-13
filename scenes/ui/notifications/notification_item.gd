extends Label

@export var life_time := 3.0
@export var fade_time := 0.3


func _ready():

	await get_tree().create_timer(life_time).timeout

	var tween = create_tween()

	tween.tween_property(self, "modulate:a", 0.0, fade_time)

	await tween.finished

	queue_free()
