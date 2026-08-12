extends Node3D

func _ready() -> void:

	_setup_nav_region()
	_gp_proof()
	_final_integration()
	_auto_start_from_main()
	_setup_joystick()
	_setup_multiplayer()

	var GM = get_node_or_null("/root/GameManager")
	if GM:
		var m = get_tree().get_first_node_in_group("monsters")
		if m:
			var nr = get_tree().get_first_node_in_group("nav_region")
			var nav_ok = nr != null
			var mesh_verts = 0
			if nr:
				var nm = nr.navigation_mesh
				if nm:
					mesh_verts = nm.get_vertices().size()
			var agent_set = false
			var na = m.find_child("NavigationAgent3D", true, false)
			if na:
				agent_set = na.target_position.distance_to(Vector3.ZERO) > 0.01




func _auto_start_from_main() -> void:
	var GM = get_node_or_null("/root/GameManager")
	if GM and GM.has_method("is_playing") and GM.is_playing():
		return
	# Главное меню открывает UIManager по событию game_state_changed(MENU).
	# Раньше здесь ещё искали узел Screens по пути "/root/Screens" — его там
	# никогда не было (Screens — потомок Main3D), так что ветка была мёртвой;
	# заодно она грозила вторым меню поверх первого.
	if GM and GM.has_method("_change_state"):
		GM._change_state(GM.GameState.MENU)

func _setup_joystick() -> void:
	# Виртуальный джойстик нужен только на тач-устройствах. На ПК он рисовался
	# всегда и вдобавок дублировал JoystickRing из hud_3d.tscn — два кольца
	# в одном углу.
	if not (DisplayServer.is_touchscreen_available() or OS.has_feature("mobile")):
		return
	var cl := CanvasLayer.new()
	cl.name = "TouchLayer"
	add_child(cl)
	var joy := Control.new()
	joy.set_script(load("res://scripts/ui/virtual_joystick.gd"))
	joy.name = "VirtualJoystick"
	joy.size = Vector2(180, 180)
	joy.anchor_left = 0.0
	joy.anchor_top = 1.0
	joy.anchor_right = 0.0
	joy.anchor_bottom = 1.0
	joy.offset_left = 24
	joy.offset_top = -204
	joy.offset_right = 204
	joy.offset_bottom = -24
	cl.add_child(joy)

func _setup_multiplayer() -> void:
	var nm := get_node_or_null("/root/NetworkManager")
	if nm == null or nm.multiplayer.multiplayer_peer == null:
		return
	var mm := Node3D.new()
	mm.set_script(load("res://scripts/multiplayer/multiplayer_manager.gd"))
	mm.name = "MultiplayerManager"
	mm.set("player_scene", preload("res://scenes/player/player_3d.tscn"))
	add_child(mm)

	var ss = get_node_or_null("ScreenShake")
	var cam = get_node_or_null("Camera3D")
	if ss and cam:
		ss.setup(cam)

func _setup_nav_region() -> void:
	var nreg := NavigationRegion3D.new()
	var nm := NavigationMesh.new()
	var S := 40.0
	nm.vertices = PackedVector3Array([Vector3(-S,0,-S),Vector3(S,0,-S),Vector3(S,0,S),Vector3(-S,0,S)])
	nm.add_polygon(PackedInt32Array([0,1,2,3]))
	nreg.navigation_mesh = nm
	nreg.add_to_group("nav_region")
	add_child(nreg)


func _gp_proof() -> void:
	var p = get_tree().get_first_node_in_group("player")
	var p_ok = p != null and p.is_inside_tree()
	var c_ok = false
	if p_ok:
		var cone = p.get_node_or_null("ModelPivot/FlashlightPivot/Flashlight")
		c_ok = cone != null and p.is_ancestor_of(cone)
	var m = get_tree().get_first_node_in_group("monsters")
	var m_ok = m != null and m.is_inside_tree()
	var nav_ok = false
	if m_ok:
		nav_ok = m.find_child("NavigationAgent3D", true, false) != null
	var nr = get_tree().get_first_node_in_group("nav_region")
	var nav_region_ok = nr != null
	if not nav_region_ok:
		nav_region_ok = get_tree().get_nodes_in_group("navigation").size() > 0



func _final_integration() -> void:
	await get_tree().create_timer(4.0).timeout
	var checks := {
		"PuzzleSystem": "/root/PuzzleSystem",
	}
	var ok: int = 0
	for nm in checks:
		if get_node_or_null(checks[nm]) != null:
			ok += 1
	var DB = load("res://scripts/inventory/item_database.gd")
	if DB:
		pass

