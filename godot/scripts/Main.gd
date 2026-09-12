extends Node2D

# ── LAYOUT ──
const CELL := 90
const GRID_X := 680.0
const GRID_Y := 120.0
const CORE_POS := Vector2(GRID_X + CELL, GRID_Y + CELL)

# 8-cell ring (clockwise from top-left), skipping center (1,1)
const RING_COORDS := [
	Vector2i(0,0), Vector2i(1,0), Vector2i(2,0),
	Vector2i(2,1),
	Vector2i(2,2), Vector2i(1,2), Vector2i(0,2),
	Vector2i(0,1)
]

# ── WEAPONS DATABASE ──
const RUNES := {
	"arrow":     {"id":"arrow",     "name":"猎弓",     "sym":"↑", "col":Color(0.78,0.63,0.25), "cd":1.5, "cost":12},
	"blade":     {"id":"blade",     "name":"铁剑",     "sym":"X", "col":Color(0.75,0.28,0.28), "cd":0.9, "cost":15},
	"shield":    {"id":"shield",    "name":"骑士盾",   "sym":"O", "col":Color(0.32,0.66,0.44), "cd":2.0, "cost":18},
	"bomb":      {"id":"bomb",      "name":"火焰法杖", "sym":"*", "col":Color(0.88,0.38,0.19), "cd":5.0, "cost":20},
	"moonblade": {"id":"moonblade", "name":"钢矛",     "sym":"/", "col":Color(0.56,0.44,0.82), "cd":2.0, "cost":16},
}

# ── WAVES ──
const WAVES := [
	{"label":"小关 1", "enemies":[{"count":6,"hp":3,"spd":80,"type":"w"},{"count":2,"hp":8,"spd":55,"type":"n"}]},
	{"label":"小关 2", "enemies":[{"count":4,"hp":3,"spd":85,"type":"w"},{"count":3,"hp":9,"spd":58,"type":"n"},{"count":1,"hp":20,"spd":40,"type":"a"}]},
	{"label":"精英关", "enemies":[{"count":4,"hp":10,"spd":60,"type":"n"},{"count":2,"hp":22,"spd":42,"type":"a"},{"count":1,"hp":32,"spd":35,"type":"e"}]},
	{"label":"Boss关", "enemies":[{"count":1,"hp":120,"spd":25,"type":"b"},{"count":2,"hp":20,"spd":60,"type":"n"}]},
]

# ── STATE ──
var gold := 20
var core_hp := 100
var wave_idx := 0
var kills := 0
var gstate := "prep"  # prep / wave / shop / over / win

var cells: Array = []        # [{coord, pos, rune, lf}]
var hand: Array = []         # [{id, name, sym, col, cd, cost, lv, kind}]
var sel_hand := -1

var shop_root: Control = null
var shop_gold_lbl: Label = null

var knight_pi := 0
var knight_step_timer := 0.0
const KNIGHT_STEP := 0.45

var enemies: Array = []
var spawn_q: Array = []
var spawn_timer := 1.5
const SPAWN_DELAY := 1.1

var shld := 0
var shld_until := 0.0

var enemy_scene := preload("res://scenes/Enemy.tscn")

# ── FLOATING NUMBERS ──
var floats: Array = []  # [{pos, vel, text, col, age, life, label}]

# ── HIT RINGS ──
var hits: Array = []  # [{pos, age, life, col}]

func _ready() -> void:
	$UI/StartWaveBtn.pressed.connect(_on_start_wave_btn_pressed)
	_init_cells()
	_init_hand()
	_update_ui()
	_show_prep_ui()

func _init_cells() -> void:
	cells = []
	for c in RING_COORDS:
		cells.append({
			"coord": c,
			"pos": Vector2(GRID_X + c.x * CELL, GRID_Y + c.y * CELL),
			"rune": null,
			"lf": -99.0
		})

func _init_hand() -> void:
	hand = []
	var a: Dictionary = RUNES["arrow"].duplicate()
	a["lv"] = 1; a["kind"] = "weapon"
	var s: Dictionary = RUNES["shield"].duplicate()
	s["lv"] = 1; s["kind"] = "weapon"
	hand.append(a)
	hand.append(s)
	sel_hand = -1
	_render_hand()

# ── UPDATE ──
func _process(delta: float) -> void:
	if gstate == "wave":
		_update_wave(delta)
	_update_floats(delta)
	for i in range(hits.size() - 1, -1, -1):
		var h: Dictionary = hits[i]
		h["age"] += delta
		if h["age"] >= h["life"]:
			hits.remove_at(i)
	queue_redraw()

func _update_wave(delta: float) -> void:
	# Spawn
	spawn_timer -= delta
	if spawn_q.size() > 0 and spawn_timer <= 0.0:
		_spawn_enemy(spawn_q.pop_front())
		spawn_timer = SPAWN_DELAY

	# Knight
	knight_step_timer += delta
	if knight_step_timer >= KNIGHT_STEP:
		knight_step_timer = 0.0
		_knight_step()

	# Enemies
	var t := Time.get_ticks_msec() / 1000.0
	for e in enemies.duplicate():
		if not is_instance_valid(e):
			enemies.erase(e); continue
		e.update_move(delta, CORE_POS)
		if e.global_position.distance_to(CORE_POS) < 35:
			if shld > 0:
				shld -= 1
				if shld == 0: shld_until = 0.0
				_float_text(CORE_POS, "格挡!", Color(0.4, 0.9, 0.5))
			else:
				core_hp -= e.atk
				_float_text(CORE_POS, "-" + str(e.atk), Color(1, 0.3, 0.3))
				hits.append({"pos": CORE_POS + Vector2(CELL * 0.5, CELL * 0.5), "age": 0.0, "life": 0.5, "col": Color(1.0, 0.3, 0.15)})
				_update_ui()
			if is_instance_valid(e):
				e.take_damage(9999)
		if not is_instance_valid(e):
			enemies.erase(e)

	if shld > 0 and t > shld_until:
		shld = 0

	if core_hp <= 0:
		_game_over()
		return

	if spawn_q.size() == 0 and enemies.size() == 0:
		_wave_done()

func _knight_step() -> void:
	knight_pi = (knight_pi + 1) % cells.size()
	$Knight.position = cells[knight_pi]["pos"] + Vector2(CELL * 0.5, CELL * 0.5)
	_fire_rune(knight_pi)

func _fire_rune(ci: int) -> void:
	var cell: Dictionary = cells[ci]
	if cell["rune"] == null: return
	var rune: Dictionary = cell["rune"]
	var t := Time.get_ticks_msec() / 1000.0
	if t - cell["lf"] < rune["cd"]: return
	cell["lf"] = t
	var lv: int = rune.get("lv", 1)
	var cpos: Vector2 = cell["pos"] + Vector2(CELL * 0.5, CELL * 0.5)

	match rune["id"]:
		"arrow":
			var nearest: Node2D = _nearest_enemy(cpos)
			if nearest:
				var dmg := 3 * lv
				_spawn_projectile(cpos, nearest.global_position, Color(0.95, 0.88, 0.35))
				nearest.take_damage(dmg)
				_float_text(nearest.global_position, str(dmg), Color(1, 0.85, 0.3))
		"blade":
			var dmg := 5 * lv
			var r := 80.0 * lv
			hits.append({"pos": cpos, "age": 0.0, "life": 0.38, "col": Color(0.95, 0.22, 0.22), "min_r": 12.0, "max_r": r})
			for e in enemies.duplicate():
				if is_instance_valid(e) and e.global_position.distance_to(cpos) < r:
					e.take_damage(dmg)
					_float_text(e.global_position, str(dmg), Color(0.9, 0.3, 0.3))
		"shield":
			shld = 2 if lv >= 3 else 1
			shld_until = t + (5.0 if lv == 3 else 3.5 if lv == 2 else 2.5)
			_float_text(CORE_POS, "护盾!", Color(0.4, 0.9, 0.5))
		"bomb":
			var dmg := 12 * lv
			var bomb_r := 110.0 * lv
			# Find centroid of nearby enemies
			var nearby := enemies.filter(func(e): return is_instance_valid(e) and (e as Node2D).global_position.distance_to(cpos) < bomb_r * 1.4)
			var target := cpos + Vector2(180, 0)
			if nearby.size() > 0:
				var sum := Vector2.ZERO
				for e in nearby:
					sum += (e as Node2D).global_position
				target = sum / nearby.size()
			# Fireball projectile
			var ball := ColorRect.new()
			ball.size = Vector2(18, 18)
			ball.color = Color(1.0, 0.55, 0.08)
			ball.position = cpos - Vector2(9, 9)
			add_child(ball)
			var tw := create_tween()
			tw.tween_property(ball, "position", target - Vector2(9, 9), 0.45)
			var captured_target := target
			var captured_r := bomb_r
			var captured_dmg := dmg
			tw.tween_callback(func() -> void:
				ball.queue_free()
				hits.append({"pos": captured_target, "age": 0.0, "life": 0.55, "col": Color(1.0, 0.48, 0.08), "min_r": 14.0, "max_r": captured_r})
				for e in enemies.duplicate():
					if is_instance_valid(e) and (e as Node2D).global_position.distance_to(captured_target) < captured_r:
						e.take_damage(captured_dmg)
						_float_text((e as Node2D).global_position, str(captured_dmg), Color(1, 0.5, 0.1))
			)
		"moonblade":
			var dmg := 7 * lv
			var sorted_e := enemies.duplicate()
			sorted_e = sorted_e.filter(func(e): return is_instance_valid(e))
			sorted_e.sort_custom(func(a,b): return a.global_position.distance_to(cpos) < b.global_position.distance_to(cpos))
			for i in min(2, sorted_e.size()):
				_spawn_projectile(cpos, sorted_e[i].global_position, Color(0.65, 0.45, 1.0))
				sorted_e[i].take_damage(dmg)
				_float_text(sorted_e[i].global_position, str(dmg), Color(0.7, 0.5, 1))

func _nearest_enemy(from: Vector2) -> Node2D:
	var best: Node2D = null
	var bd := INF
	for e in enemies:
		if is_instance_valid(e):
			var en := e as Node2D
			if en == null: continue
			var d: float = en.global_position.distance_squared_to(from)
			if d < bd: bd = d; best = en
	return best

func _spawn_enemy(data: Dictionary) -> void:
	var e = enemy_scene.instantiate()
	e.global_position = Vector2(1230, randf_range(130, 590))
	e.setup(data)
	e.connect("died", _on_enemy_died.bind(e))
	$Enemies.add_child(e)
	enemies.append(e)

func _on_enemy_died(e: Node2D) -> void:
	kills += 1
	var etype: String = e.get("etype")
	var g: int = 15 if etype=="b" else 6 if etype=="e" else 3 if etype=="h" else 4 if etype=="a" else 1 if etype=="w" else 2
	gold += g
	_float_text(e.global_position, "+"+str(g)+"g", Color(0.95, 0.85, 0.2))
	enemies.erase(e)
	_update_ui()

func _wave_done() -> void:
	wave_idx += 1
	if wave_idx >= WAVES.size():
		gstate = "win"
		$UI/PhaseLabel.text = "通关！全部 " + str(WAVES.size()) + " 波完成！"
		$UI/PhaseLabel.visible = true
		$UI/StartWaveBtn.visible = false
	else:
		gstate = "shop"
		_show_shop()

func _game_over() -> void:
	gstate = "over"
	$UI/PhaseLabel.text = "城堡沦陷！游戏结束"
	$UI/PhaseLabel.visible = true
	$UI/StartWaveBtn.visible = false

# ── SHOP ──
func _show_shop() -> void:
	if shop_root:
		shop_root.queue_free()
		shop_root = null

	var keys := RUNES.keys()
	var offerings: Array = []
	for _i in 5:
		var k: String = keys[randi() % keys.size()]
		var item: Dictionary = (RUNES[k] as Dictionary).duplicate()
		item["lv"] = 1
		item["kind"] = "weapon"
		offerings.append(item)

	shop_root = Control.new()
	shop_root.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	$UI.add_child(shop_root)

	var bg := ColorRect.new()
	bg.color = Color(0.04, 0.06, 0.14, 0.92)
	bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	shop_root.add_child(bg)

	var center := VBoxContainer.new()
	center.set_anchors_and_offsets_preset(Control.PRESET_CENTER)
	center.offset_left = -380.0
	center.offset_top = -230.0
	center.offset_right = 380.0
	center.offset_bottom = 230.0
	center.add_theme_constant_override("separation", 16)
	shop_root.add_child(center)

	var title := Label.new()
	title.text = "商  店"
	title.add_theme_font_size_override("font_size", 28)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.add_theme_color_override("font_color", Color(0.95, 0.85, 0.4))
	center.add_child(title)

	shop_gold_lbl = Label.new()
	shop_gold_lbl.text = "当前金币：" + str(gold)
	shop_gold_lbl.add_theme_font_size_override("font_size", 17)
	shop_gold_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	shop_gold_lbl.add_theme_color_override("font_color", Color(0.85, 0.78, 0.2))
	center.add_child(shop_gold_lbl)

	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 16)
	center.add_child(row)

	for item in offerings:
		row.add_child(_make_shop_card(item))

	var leave := Button.new()
	leave.text = "离开商店，前往下一关 →"
	leave.add_theme_font_size_override("font_size", 16)
	leave.custom_minimum_size = Vector2(320, 44)
	leave.pressed.connect(_leave_shop)
	center.add_child(leave)

func _make_shop_card(item: Dictionary) -> Control:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(128, 0)

	var vb := VBoxContainer.new()
	vb.add_theme_constant_override("separation", 6)
	panel.add_child(vb)

	var sym := Label.new()
	sym.text = item["sym"]
	sym.add_theme_font_size_override("font_size", 36)
	sym.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	sym.add_theme_color_override("font_color", item["col"])
	vb.add_child(sym)

	var nm := Label.new()
	nm.text = item["name"]
	nm.add_theme_font_size_override("font_size", 15)
	nm.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	vb.add_child(nm)

	var cd := Label.new()
	cd.text = "冷却 " + str(item["cd"]) + "s"
	cd.add_theme_font_size_override("font_size", 12)
	cd.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	cd.add_theme_color_override("font_color", Color(0.6, 0.7, 0.75))
	vb.add_child(cd)

	var spacer := Control.new()
	spacer.custom_minimum_size = Vector2(0, 4)
	vb.add_child(spacer)

	var btn := Button.new()
	btn.text = str(item["cost"]) + " 金币"
	btn.add_theme_font_size_override("font_size", 14)
	btn.pressed.connect(_buy_item.bind(item, btn))
	vb.add_child(btn)

	return panel

func _buy_item(item: Dictionary, btn: Button) -> void:
	if gold < item["cost"]:
		btn.text = "金币不足"
		return
	gold -= item["cost"]
	hand.append(item.duplicate())
	btn.text = "✓ 已购买"
	btn.disabled = true
	if is_instance_valid(shop_gold_lbl):
		shop_gold_lbl.text = "当前金币：" + str(gold)
	_update_ui()
	_render_hand()

func _leave_shop() -> void:
	if is_instance_valid(shop_root):
		shop_root.queue_free()
		shop_root = null
	shop_gold_lbl = null
	gstate = "prep"
	_update_ui()
	_show_prep_ui()

# ── PREP / WAVE START ──
func _show_prep_ui() -> void:
	$UI/PhaseLabel.text = "摆放武器阶段 — 点击手牌再点格子放置"
	$UI/PhaseLabel.visible = true
	$UI/StartWaveBtn.visible = true
	$UI/StartWaveBtn.text = "▶ 开始 " + WAVES[wave_idx]["label"]

func _on_start_wave_btn_pressed() -> void:
	if gstate != "prep": return
	gstate = "wave"
	$UI/PhaseLabel.visible = false
	$UI/StartWaveBtn.visible = false
	spawn_q = []
	for grp in WAVES[wave_idx]["enemies"]:
		for _i in grp["count"]:
			spawn_q.append({"hp": grp["hp"], "spd": grp["spd"], "type": grp["type"]})
	spawn_q.shuffle()
	spawn_timer = 1.5
	knight_pi = 0
	knight_step_timer = 0.0
	$Knight.position = cells[0]["pos"] + Vector2(CELL * 0.5, CELL * 0.5)

# ── UI ──
func _update_ui() -> void:
	$UI/HpLabel.text  = "核心 " + str(max(0, core_hp)) + " HP"
	$UI/GoldLabel.text = "金币 " + str(gold)
	if wave_idx < WAVES.size():
		$UI/WaveLabel.text = WAVES[wave_idx]["label"] + "  击杀:" + str(kills)

func _render_hand() -> void:
	for c in $UI/Hand.get_children():
		c.queue_free()
	for i in hand.size():
		var r: Dictionary = hand[i]
		var btn := Button.new()
		btn.text = "[" + r["name"] + " Lv" + str(r.get("lv",1)) + "]"
		btn.custom_minimum_size = Vector2(130, 44)
		btn.add_theme_font_size_override("font_size", 14)
		if sel_hand == i:
			btn.modulate = Color(1.5, 1.4, 0.5)
		btn.pressed.connect(_on_hand_btn.bind(i))
		$UI/Hand.add_child(btn)

func _on_hand_btn(i: int) -> void:
	sel_hand = i if sel_hand != i else -1
	_render_hand()

# ── DRAW ──
func _draw() -> void:
	var font := ThemeDB.fallback_font
	# Grid cells
	for i in cells.size():
		var cell: Dictionary = cells[i]
		var pos: Vector2 = cell["pos"]
		var rect := Rect2(pos, Vector2(CELL, CELL))
		draw_rect(rect, Color(0.12, 0.15, 0.2))
		draw_rect(rect, Color(0.3, 0.4, 0.55), false, 1.5)
		# Weapon overlay
		if cell["rune"] != null:
			var r: Dictionary = cell["rune"]
			var c: Color = r["col"]
			draw_rect(rect.grow(-5), Color(c.r*0.25, c.g*0.25, c.b*0.25, 0.9))
			draw_rect(rect.grow(-5), Color(c.r*0.7, c.g*0.7, c.b*0.7, 0.6), false, 1.5)
			draw_string(font, pos + Vector2(8, 30), r["name"], HORIZONTAL_ALIGNMENT_LEFT, -1, 16, c)
			draw_string(font, pos + Vector2(8, 52), "Lv" + str(r.get("lv",1)) + " cd:" + str(r["cd"]) + "s", HORIZONTAL_ALIGNMENT_LEFT, -1, 12, Color(c.r*0.8, c.g*0.8, c.b*0.8))
		else:
			draw_string(font, pos + Vector2(10, 35), "空格", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.3, 0.4, 0.45))
		# Path number
		draw_string(font, pos + Vector2(4, 14), str(i+1), HORIZONTAL_ALIGNMENT_LEFT, -1, 11, Color(0.4, 0.5, 0.6))

	# Core
	var core_rect := Rect2(GRID_X + CELL, GRID_Y + CELL, CELL, CELL)
	draw_rect(core_rect, Color(0.18, 0.25, 0.45))
	draw_rect(core_rect, Color(0.4, 0.6, 0.95), false, 2)
	var hp_ratio := float(core_hp) / 100.0
	draw_rect(Rect2(GRID_X + CELL, GRID_Y + CELL + CELL - 8, CELL * hp_ratio, 8), Color(0.3, 0.7, 0.35))
	draw_string(font, Vector2(GRID_X + CELL + 8, GRID_Y + CELL + 42), "城堡", HORIZONTAL_ALIGNMENT_LEFT, -1, 18, Color(0.7, 0.85, 1))

	# Shield glow
	if shld > 0:
		draw_rect(core_rect.grow(6), Color(0.3, 0.8, 0.45, 0.35 + sin(Time.get_ticks_msec() * 0.005) * 0.15), false, 3)

	# Knight body
	var kpos: Vector2 = ($Knight as Node2D).position
	draw_circle(kpos, 14, Color(0.85, 0.72, 0.2))
	draw_circle(kpos, 14, Color(1.0, 0.9, 0.3), false, 2)
	draw_string(font, kpos - Vector2(10, -6), "骑士", HORIZONTAL_ALIGNMENT_LEFT, -1, 13, Color(0.1, 0.1, 0.1))

	# Hit rings
	for h in hits:
		var ratio: float = h["age"] / h["life"]
		var min_r: float = h.get("min_r", 18.0)
		var max_r: float = h.get("max_r", 78.0)
		var ring_r: float = min_r + ratio * (max_r - min_r)
		var ring_a: float = (1.0 - ratio) * 0.8
		var hc: Color = h["col"]
		draw_arc(h["pos"], ring_r, 0.0, TAU, 36, Color(hc.r, hc.g, hc.b, ring_a), 3.0)
		draw_arc(h["pos"], ring_r * 0.6, 0.0, TAU, 28, Color(hc.r, hc.g, hc.b, ring_a * 0.45), 1.5)

# ── FLOATING TEXT ──
func _update_floats(_delta: float) -> void:
	pass  # handled by tween

func _spawn_projectile(from: Vector2, to: Vector2, col: Color) -> void:
	var ln := Line2D.new()
	ln.add_point(from)
	ln.add_point(from)
	ln.default_color = col
	ln.width = 3.0
	add_child(ln)
	var tw := create_tween()
	tw.tween_method(func(p: Vector2): ln.set_point_position(1, p), from, to, 0.12)
	tw.tween_interval(0.06)
	tw.tween_callback(ln.queue_free)

func _float_text(pos: Vector2, text: String, col: Color) -> void:
	var lbl := Label.new()
	lbl.text = text
	lbl.position = pos - Vector2(20, 20)
	lbl.add_theme_color_override("font_color", col)
	lbl.add_theme_font_size_override("font_size", 16)
	add_child(lbl)
	var tw := create_tween()
	tw.tween_property(lbl, "position", lbl.position + Vector2(0, -55), 0.9)
	tw.parallel().tween_property(lbl, "modulate:a", 0.0, 0.9)
	tw.tween_callback(lbl.queue_free)

# ── INPUT (cell click) ──
func _input(event: InputEvent) -> void:
	if gstate != "prep": return
	if not (event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT):
		return
	var mpos := get_global_mouse_position()
	for i in cells.size():
		var cell: Dictionary = cells[i]
		var rect := Rect2(cell["pos"], Vector2(CELL, CELL))
		if rect.has_point(mpos):
			_on_cell_click(i)
			return

func _on_cell_click(ci: int) -> void:
	var cell: Dictionary = cells[ci]
	if sel_hand >= 0 and sel_hand < hand.size():
		var item: Dictionary = hand[sel_hand]
		if item.get("kind") == "weapon":
			if cell["rune"] != null:
				hand.append(cell["rune"].duplicate())
			cell["rune"] = item.duplicate()
			cell["lf"] = -99.0
			hand.remove_at(sel_hand)
			sel_hand = -1
			_render_hand()
			queue_redraw()
	else:
		if cell["rune"] != null:
			hand.append(cell["rune"].duplicate())
			cell["rune"] = null
			sel_hand = hand.size() - 1
			_render_hand()
			queue_redraw()
