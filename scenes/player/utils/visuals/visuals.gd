class_name PlayerUtilsVisuals
extends PlayerUtilsProvider

func _init(player: Player):
	super(player)
	p.ready.connect(_refresh)
	p.color_changed_sig.connect(apply_color)

func _refresh():
	apply_color()
	apply_sid_label()

func apply_color():
	if !p.is_node_ready(): 
		# the spawn callback sets color before the node is in the tree
		return

	var mat: StandardMaterial3D = p.body.material_override
	if mat == null:
		mat = StandardMaterial3D.new()
		p.body.material_override = mat
	mat.albedo_color = p.color

func apply_sid_label():
	p.sid_label.text = "#%d" % (p.sid + 1)
