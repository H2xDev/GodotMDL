class_name PHYReader extends RefCounted

class PHYHeader:
	var size: int;
	var id: int;
	var solid_count: int;
	var checksum: int;

	func _to_string():
		return "PHYHeader: {size: %d, id: %d, solid_count: %d, checksum: %d}" % [size, id, solid_count, checksum]

class PHYSurfaceHeader:
	static var max_deviation: int = 8;
	static var byte_size: int = 24;

	var size: int;
	var id: String;
	var version: int;
	var surface_size: int;
	var model_type: int;
	var dragAxisAreas: Vector3;
	var axisMapSize: int;

	func _to_string():
		return "PHYSurfaceHeader: {size: %d, id: %s, version: %d, surface_size: %d, dragAxisAreas: %s, axisMapSize: %d}" % [size, id, version, surface_size, dragAxisAreas, axisMapSize]

var header: PHYHeader;
var surfaces: Array[PHYSurfaceHeader] = [];

func _init(source_file: String):
	var file = FileAccess.open(source_file, FileAccess.READ);
	if file == null: return;

	header = ByteReader.read_by_structure(file, PHYHeader, {
		size 											= ByteReader.Type.INT,
		id 												= ByteReader.Type.INT,
		solid_count 							= ByteReader.Type.INT,
		checksum 									= ByteReader.Type.INT,
	});

	for i in range(header.solid_count):
		var surface_header = ByteReader.read_by_structure(file, PHYSurfaceHeader, {
			size 											= ByteReader.Type.INT,
			id 												= [ByteReader.Type.STRING, 4],
			version 									= ByteReader.Type.SHORT,
			model_type 								= ByteReader.Type.SHORT,
			surface_size 							= ByteReader.Type.INT,
			dragAxisAreas 						= ByteReader.Type.VECTOR3,
			axisMapSize 							= ByteReader.Type.INT,
		});

		surfaces.append(surface_header);
