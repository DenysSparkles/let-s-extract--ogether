extends StaticBody3D

var hp := 1000

func take_damage(dmg):
	hp -= dmg
	print("Enemy HP:", hp)
# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
