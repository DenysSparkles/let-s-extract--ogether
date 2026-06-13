extends Control

@onready var container = $VBoxContainer

@export var notification_scene : PackedScene


func add_notification(text : String):

	var item = notification_scene.instantiate()

	item.text = text

	container.add_child(item)
