extends Node2D

signal died

var hp: float = 10
var max_hp: float = 10
var spd: float = 60.0
var atk: int = 3
var etype: String = "n"

var slowed_until: float = 0.0
var poison_until: float = 0.0
var poison_dps: float = 0.0

func setup(data: Dictionary) -> void:
	etype = data.get("type", "n")
	hp = data.get("hp", 10)
	max_hp = hp
	spd = float(data.get("spd", 60))
	atk = 12 if etype == "b" else 7 if etype == "e" else 5 if etype in ["a","h"] else 1 if etype == "w" else 3
	_update_visuals()

func _update_visuals() -> void:
	var sz: float = 20.0 if etype == "b" else 14.0 if etype == "e" else 8.0 if etype == "w" else 12.0
	var col: Color
	match etype:
		"b": col = Color(0.6, 0.1, 0.1)
		"e": col = Color(0.35, 0.1, 0.55)
		"a": col = Color(0.2, 0.25, 0.45)
		"h": col = Color(0.1, 0.4, 0.25)
		"w": col = Color(0.5, 0.25, 0.25)
		_:   col = Color(0.65, 0.15, 0.15)
	$Body.color = col
	$Body.size = Vector2(sz * 2, sz * 2)
	$Body.position = Vector2(-sz, -sz * 2)
	$HpBar.max_value = max_hp
	$HpBar.value = hp
	$HpBar.size.x = sz * 2 + 4
	$HpBar.position = Vector2(-sz - 2, -sz * 2 - 8)

func take_damage(dmg: float) -> void:
	hp -= dmg
	if is_instance_valid($HpBar):
		$HpBar.value = max(0, hp)
	if hp <= 0:
		emit_signal("died")
		queue_free()

func update_move(delta: float, target: Vector2) -> void:
	var t := Time.get_ticks_msec() / 1000.0
	var s := spd * (0.6 if t < slowed_until else 1.0)
	var dir := (target - global_position).normalized()
	global_position += dir * s * delta
	if t < poison_until:
		take_damage(poison_dps * delta)
