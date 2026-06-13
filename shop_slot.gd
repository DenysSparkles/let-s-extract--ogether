extends Panel

@onready var icon = $Icon
@onready var price_label = $PriceLabel
@onready var name_label = $NameLabel
@onready var background = $Background
var item_data
var tooltip

func setup(item, tooltip_ref):
	item_data = item
	tooltip = tooltip_ref
	icon.texture = item.icon
	name_label.text = item.item_name
	price_label.text = (
		"$" + str(item.value)
	)
	background.color = (
		item_data.get_rarity_color()
	)

func _gui_input(event):
	if event is InputEventMouseButton:
		if (
			event.button_index == MOUSE_BUTTON_LEFT
			and event.pressed
		):
			buy_item()

func buy_item():
	if GameManager.money < item_data.value:
		var notifications = (
			get_tree()
			.get_first_node_in_group(
				"notifications"
			)
		)
		if notifications:
			notifications.add_notification(
				"Not enough money"
			)
		return
	var success = (
		GameManager.stash_inventory.add_item(
			item_data,
			1
		)
	)
	if not success:
		return
	var notifications = get_tree().get_first_node_in_group(
	"notifications"
)

	if notifications:

		notifications.add_notification(
			"Bought " + item_data.item_name
		)
	GameManager.money -= item_data.value
	SaveSystem.save_game()
	var ui = get_tree().get_first_node_in_group(
		"inventory_ui"
	)
	if ui:
		ui.update_inventory()
		ui.update_money_ui()

func _on_mouse_entered():

	if tooltip == null:
		return

	tooltip.visible = true

	tooltip.get_node("Label").text = (
		item_data.item_name
		+ "\n\n"
		+ item_data.get_category_name()
		+ "\n"
		+ "Weight: "
		+ str(item_data.weight)
		+ " kg"
		+ "\n"
		+ "Value: $"
		+ str(item_data.value)
		+ "\n\n"
		+ item_data.description
	)

func _on_mouse_exited():

	if tooltip:

		tooltip.visible = false
