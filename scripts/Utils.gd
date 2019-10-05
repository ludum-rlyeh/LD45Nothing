extends Node

# return a copy of a given array without duplicates
func remove_duplicates(var array):
	var n_array = []
	for val in array:
		if not n_array.has(val):
			n_array.append(val)
	return n_array
