class_name PHYReader extends RefCounted

class PHYHeader:
	static var scheme:
		get: return {
		size 											= ByteReader.Type.INT,
		id 												= ByteReader.Type.INT,
		solid_count 									= ByteReader.Type.INT,
		checksum 										= ByteReader.Type.INT,
	};

	var size: int;
	var id: int;
	var solid_count: int;
	var checksum: int;

	var address: int = 0;

	func _to_string():
		return "PHYHeader: {size: %d, id: %d, solid_count: %d, checksum: %d}" % [size, id, solid_count, checksum];

class PHYSurfaceHeader:
	static var scheme:
		get: return {
		size 											= ByteReader.Type.INT,
		id 												= [ByteReader.Type.STRING, 4],
		version 										= ByteReader.Type.SHORT,
		model_type 										= ByteReader.Type.SHORT,
		surface_size 									= ByteReader.Type.INT,
		drag_axis_areas 								= ByteReader.Type.VECTOR3,
		axis_map_size 									= ByteReader.Type.INT,
	};	

	var size: int;
	var id: String;
	var version: int;
	var surface_size: int;
	var model_type: int;
	var drag_axis_areas: Vector3;
	var axis_map_size: int;

	var address = 0;

	func _to_string():
		return "PHYSurfaceHeader: {size: %d, id: %s, version: %d, model_type: %d, surface_size: %d, drag_axis_areas: %s, axis_map_size: %d}" % [size, id, version, model_type, surface_size, drag_axis_areas, axis_map_size]

var header: PHYHeader;
var surfaces: Array[PHYSurfaceHeader] = [];

func _init(source_file: String):
	var file = FileAccess.open(source_file, FileAccess.READ);
	if file == null: return;

	header = ByteReader.read_by_structure(file, PHYHeader);

	for i in range(header.solid_count):
		var surface_header = ByteReader.read_by_structure(file, PHYSurfaceHeader);
		surfaces.append(surface_header);
