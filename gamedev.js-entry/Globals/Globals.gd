extends Node


var ground_position_marker : Marker2D


var left_boundary_marker : Marker2D
var right_boundary_marker : Marker2D

var left_ground_marker : Marker2D
var right_ground_marker : Marker2D


var claw : Claw


var cam : Camera2D


var level_node : Node2D


var endless_mode : bool = false


func apply_cam_shake(strength : float):
	cam.add_trauma(strength)
