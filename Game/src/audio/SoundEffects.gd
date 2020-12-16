extends Node

onready var root_node = get_tree().get_root()
onready var chocolate_counter = root_node.find_node("ChocolateCounter", true, false)
onready var player = root_node.find_node("Player", true, false)
onready var complete_trophy = root_node.find_node("CompleteTrophy", true, false)
signal death_sound_finished
signal win_sound_finished

func _ready():
	chocolate_counter.connect("chocolate_collected", self, "eat_cookie")
	player.connect("player_jump", self, "jump")
	player.connect("hit_enemy", self, "hit_enemy")
	player.connect("get_hit", self, "get_hit")
	player.connect("die", self, "die")
	complete_trophy.connect("player_finishing_level", self, "finish_level")


func eat_cookie():
	$eat_cookie.playing = true


func jump():
	$jump.playing = true


func hit_enemy():
	$hit_enemy.playing = true


func get_hit():
	$get_hit.playing = true


func die():
	$death.playing = true
	$bg_audio.playing = false
	yield ($death, "finished")
	emit_signal("death_sound_finished")


func finish_level():
	$finish_level.playing = true
	yield ($finish_level, "finished")
	emit_signal("win_sound_finished")


