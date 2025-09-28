extends CharacterBody2D
const SPEED = 100.0
var MaxHealth = 20
var Health = MaxHealth
func _ready() -> void:
	$TextureProgressBar.max_value = MaxHealth
	$TextureProgressBar.value = Health
func _physics_process(delta: float) -> void:
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
func _process(delta: float) -> void:
	$TextureProgressBar.max_value = MaxHealth
	$TextureProgressBar.value = Health
