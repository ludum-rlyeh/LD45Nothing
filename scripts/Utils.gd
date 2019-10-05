extends Node

# return a copy of a given array without duplicates
func remove_duplicates(var array):
	var n_array = []
	for val in array:
		if not n_array.has(val):
			n_array.append(val)
	return n_array

# test and teleport boid if out of viewport
func out_of_viewport(var boid):
	var viewport_size = get_viewport().get_size()
	
	if boid.position.x < -viewport_size.x/4.0 :
		boid.position.x = viewport_size.x + viewport_size.x/4.0
	elif boid.position.x > viewport_size.x + viewport_size.x/4.0 :
		boid.position.x = -viewport_size.x/4.0
	
	if boid.position.y < -viewport_size.y / 4.0 :
		boid.position.y = viewport_size.y + viewport_size.y / 4.0
	elif boid.position.y > viewport_size.y + viewport_size.y / 4.0:
		boid.position.y = - viewport_size.y / 4.0
