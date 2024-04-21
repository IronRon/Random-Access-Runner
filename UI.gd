extends Control

var difficulty = ""

signal quit
signal retry
signal start(difficulty)

@onready var timer = $HealthBar/Timer
@onready var damage_bar = $HealthBar/DamageBar
@onready var health_bar = $HealthBar

var health = 0 : set = _set_health
func _set_health(new_health):
	var prev_health = health
	health = min(health_bar.max_value, new_health)
	health_bar.value = health
	
	if health <=0:
		health_bar.queue_free()
		
	if health < prev_health:
		timer.start()
	else:
		damage_bar.value = health

var orb_collected = 0
var terminals_restored = 0
var terminals : String = "0" : set = set_number_of_terminals
func set_number_of_terminals(val:String)->void:
	terminals = val

enum OrbType {
	STRENGTH,
	SPEED,
	JUMP,
	DENSITY,
	BLOCK,
	BLOCK_SPAM
}

# Called when the node enters the scene tree for the first time.
func _ready():
	text_update()
	init_health(100)
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	

func init_health(_health):
	health = _health
	health_bar.max_value = health
	health_bar.value = health
	damage_bar.max_value = health
	damage_bar.value = health


func _orb_collected(orb_type):
	
	orb_collected += 1
	match orb_type:
		OrbType.STRENGTH:
			$OrbPickUpRect/PickUpText.text = "STRENGTH Orb Collected"
			
		OrbType.SPEED:
			$OrbPickUpRect/PickUpText.text = "SPEED Orb Collected"
			
		OrbType.JUMP:
			$OrbPickUpRect/PickUpText.text = "JUMP Orb Collected"
			
		OrbType.DENSITY:
			$OrbPickUpRect/PickUpText.text = "DENSITY Orb Collected"
			
		OrbType.BLOCK:
			$OrbPickUpRect/PickUpText.text = "BLOCK Orb Collected"
			
		OrbType.BLOCK_SPAM:
			$OrbPickUpRect/PickUpText.text = "BLOCK_SPAM Orb Collected"
	text_update()

func _terminal_restored():
	terminals_restored += 1
	text_update()
	
func _prompt_update(prompt: String):
	$Prompt.text = prompt

func text_update():
	$OrbCollectedLabel.text = "Orbs Collected: %s/6" % orb_collected
	$TerminalsRestoredLabel.text = "Terminals Restored: %s/%s" % [terminals_restored, terminals]
	
func died_rect():
	$Menu.color = Color.hex(0xff161753)
	$Menu/DeadText.visible = true
	_show_menu()
	
func player_hit(damage):
	health -= damage
	$HitRect.visible = true
	await get_tree().create_timer(0.2).timeout
	$HitRect.visible = false

	
func orb_rect():
	$OrbPickUpRect.visible = true
	await get_tree().create_timer(0.2).timeout
	$OrbPickUpRect.visible = false


func _on_quit_buuton_pressed():
	quit.emit()

func _on_retry_button_pressed():
	_on_close_pressed()
	retry.emit()

func _show_menu():
	get_tree().paused = true
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	$Menu.show()

func _on_close_pressed():
	$Menu.hide()
	$Menu/DeadText.visible = false
	$Menu.color = Color.hex(0x0000002c)
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	get_tree().paused = false

func _on_start_pressed():
	$StartScreen.hide()
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED
	start.emit(difficulty)
	

func _on_timer_timeout():
	damage_bar.value = health

func _on_hard_pressed():
	difficulty = "hard"
	_on_start_pressed()

func _on_easy_pressed():
	difficulty = "easy"
	_on_start_pressed()

func _on_normal_pressed():
	difficulty = "normal"
	_on_start_pressed()
