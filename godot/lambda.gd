class_name Lambda
extends Node2D

var vel := Vector2.ZERO
@export var bind := -1
@export var fn : Lambda
@export var ip : Lambda

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if ip:
		var push = ip.position - position - Vector2(512, -256)
		vel += push * delta * 160
		ip.vel -= push * delta * 160
	if fn:
		var push = fn.position - position - Vector2(0, -512)
		vel += push * delta * 160
		fn.vel -= push * delta * 160
	if bind > -1:
		vel.y = (bind * 256 - global_position.y) * 16
	vel *= 0.9
	position += vel * delta
	queue_redraw()

func _draw():
	if ip:
		var corner = Vector2(ip.position.x, position.y)
		draw_line(Vector2(-64, 0), corner - position + Vector2(64, 0), Color.AQUA, 128)
		draw_line(corner - position, ip.position - position, Color.AQUA, 128)
	if fn:
		draw_line(Vector2.ZERO, fn.position - position, Color.AQUA, 128)
	if bind > -1:
		draw_line(Vector2(-192, 0), Vector2(192, 0), Color.AQUA, 128)
