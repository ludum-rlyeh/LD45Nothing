extends Node

var THRESHOLD_ANGLE_SAME_SLOPE = 0.8
var DIST_SAME_POINT = 10

func reverse_index(i, size):
	return size - i - 1

func process_normal_3_points(var i, var pts):
	var v = pts[i] - pts[i+1]
	var n1 = Vector2(-v.y, v.x)
	
	var v2 = pts[i-1] - pts[i]
	var n2 = Vector2(-v2.y, v2.x)
	
	return (n1 + n2) / 2.0

#func _ready():
#	print(incrementIndexInArray(5, 3, 6))
#	print(decrementIndexInArray(3, 8, 6))
#
#	var pt1 = Vector2(0,0)
#	var pt2 = Vector2(2,2)
#	print(isInEdge(Vector2(1,1).normalized(), pt1, pt2, THRESHOLD_ANGLE_SAME_SLOPE))
#	pt2 = Vector2(4,2)
#	print(isInEdge(Vector2(1,1).normalized(), pt1, pt2, THRESHOLD_ANGLE_SAME_SLOPE))
#
#	var points = [Vector2(0,0), Vector2(2,2), Vector2(4,4.1), Vector2(2,3), Vector2(2, 0), Vector2(-3,-3)]
#	print(detectEdge(0, points))
#	print(detectEdge(3, points))

func get_barycenter(points):
	var bary = Vector2.ZERO
	for pt in points:
		bary += pt
	bary /= points.size()
	return bary
	
func get_barycenter_from_edges(edges):
	var bary = Vector2.ZERO
	for edge in edges:
		bary += edge[0]
	bary /= edges.size()
	return bary
		
func apply_translation(tab : Array, var T):
	for i in tab.size():
		tab[i] += T
	return tab

func getBBox(points):
	var rect = Rect2(points[0], Vector2(0.0,0.0))
	for point in points:
		rect = rect.expand(point)
	return rect
	
	

# return a copy of a given array without duplicates
func remove_duplicates(var array):
	var n_array = []
	for val in array:
		if not n_array.has(val):
			n_array.append(val)
	return n_array
	
# split the list of points in a list of edges (array of array of 2 points)
func splitByEdges(points : Array, line_closed : bool):
	var nb_points = points.size()
	var edges = []
	if nb_points < 2:
		return edges
	var edge_indexes = detectEdge(0, points)
	edges.append([points[edge_indexes.start], points[edge_indexes.end]])
#	print(edge_indexes)
	
	while edge_indexes.end != nb_points - 1:
		edge_indexes = detectEdge(edge_indexes.end, points)
#		print(edge_indexes)
		edges.append([points[edge_indexes.start], points[edge_indexes.end]])
		
		
	if edges.size() > 1 && line_closed:
		var first_edge = edges[0]
		var last_edge = edges[-1]
		var slope1 = getNormalizedVector(first_edge[0], first_edge[1])
		if isInEdge(slope1, last_edge[0], last_edge[1], THRESHOLD_ANGLE_SAME_SLOPE):
			var end_pt = last_edge[1]
			edges.pop_back()
			edges[0][1] = end_pt

	edges = mergeEdgesWithCloseSlopes(edges)
			
	return edges
	
func mergeEdgesWithCloseSlopes(edges):
	var edges_out = []
	for i in edges.size():
		var slope = edges[i-1][0] - edges[i-1][1]
		var slope2 = edges[i][0] - edges[i][1]
#		print("DOT : ", slope.normalized().dot(slope2.normalized()))
		if slope.length() < DIST_SAME_POINT || slope.normalized().dot(slope2.normalized()) > THRESHOLD_ANGLE_SAME_SLOPE:
			edges[i][0] = edges[i-1][0]
		else:
			edges_out.append(edges[i-1])
	
#	var slope = edges_out[0][0] - edges_out[0][1]
#	var slope2 = edges_out[-1][0] - edges_out[-1][1]
#	if slope.length() < DIST_SAME_POINT || slope.normalized().dot(slope2.normalized()) > THRESHOLD_ANGLE_SAME_SLOPE:
#		edges_out[0][0] = edges_out[-1][0]
#		edges_out.pop_back()
	return edges_out
		
#detect at the point indice the next edge and return it
func detectEdge(indice, points):
	var nb_points = points.size()
	var init_pt = points[indice]
	var slopeVec = getNormalizedVector(init_pt, points[indice + 1])
	
	#end starts at the second checked point (because the two first are used for building the slope vector
	var end = indice
	var offset = end + 2
	
	if !isValidIndex(offset, points):
		return {"start" : indice, "end" : offset - 1}
		
	while isInEdge(slopeVec, points[offset-1], points[offset], THRESHOLD_ANGLE_SAME_SLOPE):
#		print("is_in_edge : ", offset)
		offset = offset + 1
		if !isValidIndex(offset, points):
			break
		
	end = offset - 1

	return {"start" : indice, "end" : end}

# checks if the index is inside the input array	
func isValidIndex(index, array):
	if index >= array.size():
		return false
	return true
	
# check if the target_pt is in the same edge with the slope slopeVec
func isInEdge(slopeVec : Vector2, init_pt : Vector2, target_pt : Vector2, offset : float):
	
#	print ("is in edge, slopeVec : ", slopeVec, " ; init_pt : ", init_pt , "; target_pt : ", target_pt, "; offset : ", offset)
	var slopeVec2 = getNormalizedVector(init_pt, target_pt)
#	print("slopeVec2 : ", slopeVec2)
	var dot_slope = slopeVec.dot(slopeVec2)
#	print ("dot slope : ", dot_slope)
#	print("comparaison : ", init_pt, target_pt, slopeVec2, " angle : " , dot_slope)
	return abs(dot_slope) >= offset
	
#func incrementIndexInArray(var indice, var inc, var size):
#	return (indice + inc) % size
#
#func decrementIndexInArray(var indice, var inc, var size):
#	var offset = indice - inc
#	if offset < 0:
#		return size + offset
#	return offset
	
func getVector(pt1, pt2):
	return pt2 - pt1
	
func getNormalizedVector(pt1, pt2):
	return getVector(pt1, pt2).normalized()

# test and teleport boid if out of viewport
func out_of_viewport(var boid):
	var viewport_size = get_viewport().get_size()
	var changed = 0
	var size = boid.size
	
	if boid.position.x < - size.x * 2.0 :
		boid.position.x = viewport_size.x * 1.5
		changed = 1
	elif boid.position.x > viewport_size.x * 2.0 :
		boid.position.x = - size.x * 1.5
		changed = 1
	
	if boid.position.y < - size.y * 2.0 :
		boid.position.y = viewport_size.y * 1.5
		changed = 1
	elif boid.position.y > viewport_size.y * 2.0:
		boid.position.y = - size.y * 1.5
		changed = 1
	
	return changed

func Viewport_dimensions() :
	return get_viewport().get_size()
	
func split_in_subarrays(array, size):
	var arrays = []
	while array.size() > size:
		var pts = split_array(array, size)
		arrays.append(array.duplicate())
		array = pts
	if array.size():
		arrays.append(array.duplicate())
	return arrays
	
func split_array(array, indice):
	var array2 = []
	for i in range(indice, array.size()):
		array2.append(array[i])
	array.resize(indice)
	return array2