extends CharacterBody2D
class_name PlagueBall

@export var speed := 400
@export var damage := 5
@export var poison_damage := 2
@export var poison_duration := 4.0
@export var poison_interval := 1.0
@export var lifetime := 4.0
func _ready():
	connect("area_entered", Callable(self, "_on_area_entered"))
# Wait for lifetime seconds, then delete the projectile
	await get_tree().create_timer(lifetime).timeout
	queue_free()
func _physics_process(delta):
	# Move the projectile
	position += velocity * delta
func _on_area_entered(area):
	var target = area.get_parent()
	if target and target.has_method("apply_poison"):
		if target.has_method("take_damage"):
			target.take_damage(damage)
			target.apply_poison(poison_damage, poison_duration, poison_interval)
	queue_free()  # Destroy projectile on hit
	
