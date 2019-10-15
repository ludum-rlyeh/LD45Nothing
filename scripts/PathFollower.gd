extends Node

var _path = []
var _line

func _init(line : Line2D):
	_line = line
	for i in _get_nb_active_points() - 1:
		_add_local_path(_get_pt_pos2(i+1), i)

func move(displacement):
#	print("move : ", displacement)
	_translate_position(_get_nb_active_points()-1, displacement)
	_add_local_path2(_get_head_active_point())
	var size_path = _path.size()
	for i in size_path:
		var path_i = Utils.reverse_index(i, size_path)
		_move_points_throw_path(path_i, displacement.length())
	_clear_path()
		
func _move_points_throw_path(local_path_i, displacement_length):
	var local_pt_j = 0
	while local_pt_j < _path[local_path_i].pts.size():
		var is_pt_change_path = _move_point_through_path(local_path_i, local_pt_j, displacement_length)
		if !is_pt_change_path:
			local_pt_j += 1

func _move_point_through_path(local_path_i : int, local_pt_j : int, global_displacement_length : float):
	var local_path_pt = _get_local_path_pt(local_pt_j, local_path_i)
	var is_pt_change_path = false
#	print("=================================================")
#	print("old local pt : ", local_path_pt, " ", _get_pt_pos(local_path_pt))
	
	var pt_pos = _get_pt_pos(local_path_pt)
	var remained_local_displacement = _get_remained_local_displacement(pt_pos, local_path_pt.dest_pos)
	var remained_global_displacement_length = global_displacement_length
	
	while remained_global_displacement_length >= 0:
		var is_pt_still_inside_local_path = remained_global_displacement_length == 0 || remained_global_displacement_length < remained_local_displacement.length
#		print(remained_global_displacement_length, " ", remained_local_displacement.length)
		if is_pt_still_inside_local_path:
			var displacement = remained_local_displacement.dir * remained_global_displacement_length
#			print("displacement : ", remained_local_displacement.origin, " + ", displacement)
			_update_position(local_path_pt, remained_local_displacement.origin + displacement) 
			break
		else:
			remained_global_displacement_length -= remained_local_displacement.length
			var origin_pos = local_path_pt.dest_pos
			local_path_pt = _transfert_pt_to_next_path(local_path_pt)
			is_pt_change_path = true
			# get the new displacement on the whole next local path
			_update_remained_local_displacement(remained_local_displacement, origin_pos, local_path_pt.dest_pos)
			
#	print("new local pt : ", local_path_pt, " ", _get_pt_pos(local_path_pt))
#	print("=================================================")
	
	return is_pt_change_path

func _get_remained_local_displacement(pt, pt_dest):
	return {"origin" : pt, "dir" : (pt_dest - pt).normalized(), "length" : pt.distance_to(pt_dest)}
	
func _update_remained_local_displacement(local_pt, pt, pt_dest):
	local_pt.origin = pt
	local_pt.dir = (pt_dest - pt).normalized()
	local_pt.length = pt.distance_to(pt_dest)
	
func _get_local_path_pt(local_pt_j, local_path_i):
	return {"index_in_path" : local_pt_j, "path_i" : local_path_i, "dest_pos" : _path[local_path_i].pt_dest}
	
func _get_pt_global_index2(path_i : int, index : int):
	return _path[path_i].pts[index]
	
func _get_pt_global_index(local_pt):
	return _get_pt_global_index2(local_pt.path_i, local_pt.index_in_path)
	
func _get_pt_pos(local_pt):
	return _get_pt_pos2(_get_pt_global_index(local_pt))
	
func _get_pt_pos2(index : int):
	return _line.get_point_position(index)
		
func _transfert_pt_to_next_path(local_path_pt):
	var global_index = _get_pt_global_index(local_path_pt)
	_remove_pt_from(local_path_pt.path_i, local_path_pt.index_in_path)
	var next_local_path_i = local_path_pt.path_i + 1
	_add_pt_to(next_local_path_i, global_index)
	
	return _get_local_path_pt(_get_nb_points_local_path(next_local_path_i)-1, next_local_path_i)
	
func _get_nb_points_local_path(path_i):
	return _path[path_i].pts.size()
	
func _remove_pt_from(local_path_i : int, pt_i : int):
	_path[local_path_i].pts.remove(pt_i)
	
#return the pt index in the local path i
func _add_pt_to(local_path_i : int, pt_index : int):
	_path[local_path_i].pts.push_back(pt_index)
	return _get_nb_points_local_path(local_path_i) - 1
		
func _clear_path():
	while _path.front().pts.size() == 0:
		_path.pop_front()
		
func _translate_position(pt_global_index, displacement):
	_line.set_point_position(pt_global_index, _line.get_point_position(pt_global_index) + displacement)
	
func _update_position(local_pt, new_pos):
	_line.set_point_position(_get_pt_global_index(local_pt), new_pos)
	
func _get_nb_active_points():
	return _line.get_point_count()

func _add_local_path(pos, index):
	_path.push_back(_get_local_path(pos, index))
	
func _add_local_path2(pos):
	_path.push_back(_get_local_path2(pos))
	
func _get_head_active_point():
	return _get_pt_pos2(_get_nb_active_points()-1)
	
func _get_local_path(pos, index):
	return {"pt_dest" : pos, "pts" : [index]}
	
func _get_local_path2(pos):
	return {"pt_dest" : pos, "pts" : []}