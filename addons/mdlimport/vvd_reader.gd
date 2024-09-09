class_name VVDReader extends RefCounted

const MAX_NUM_LODS = 8;

class VVDHeader:
	static var scheme:
		get: return {
		id 							= ByteReader.Type.INT,
		version 					= ByteReader.Type.INT,
		checksum 					= ByteReader.Type.INT,
		num_lods 					= ByteReader.Type.INT,
		num_lods_vertexes 			= [ByteReader.Type.INT, MAX_NUM_LODS],
		num_fixups 					= ByteReader.Type.INT,
		fixup_table_offset 			= ByteReader.Type.INT,
		vertex_data_offset 			= ByteReader.Type.INT,
		tangent_data_offset 		= ByteReader.Type.INT,
	}

	var id: int
	var version: int
	var checksum: int
	var num_lods: int
	var num_lods_vertexes: Array[int] = [];
	var num_fixups: int
	var fixup_table_offset: int
	var vertex_data_offset: int
	var tangent_data_offset: int

	func _to_string() -> String:
		return "VVDHeader: id=%d, version=%d, checksum=%d, num_lods=%d, num_lods_vertexes=%s, num_fixups=%d, fixup_table_offset=%d, vertex_data_offset=%d, tangent_data_offset=%d" % [id, version, checksum, num_lods, num_lods_vertexes, num_fixups, fixup_table_offset, vertex_data_offset, tangent_data_offset]

class VVDFixupTable:
	static var scheme: 
		get: return {
		lod 						= ByteReader.Type.INT,
		source_vertex_id 			= ByteReader.Type.INT,
		num_vertexes 				= ByteReader.Type.INT
	}

	var lod: int
	var source_vertex_id: int;
	var num_vertexes: int;
	var dist_index: int;

	func _to_string() -> String:
		return "VVDFixupTable: lod=%d, source_vertex_id=%d, num_vertexes=%d" % [lod, source_vertex_id, num_vertexes]

class VVDBoneWeight:
	static var scheme:
		get: return {
		weight 						= [ByteReader.Type.FLOAT, 3],
		bone 						= [ByteReader.Type.CHAR, 3],
		num_bones 					= ByteReader.Type.BYTE,
	}

	var weight: Array[float] = [];
	var bone: Array[int] = [];
	var num_bones: int;

	func _to_string() -> String:
		return "VVDBoneWeight: weight=%s, bone=%s, num_bones=%d" % [weight, bone, num_bones]

class VVDVertexData:
	static var scheme:
		get: return {
		position 					= ByteReader.Type.VECTOR3,
		normal 						= ByteReader.Type.VECTOR3,
		uv 							= ByteReader.Type.VECTOR2,
	}

	var position: Vector3
	var normal: Vector3
	var uv: Vector2
	var bone_weight: VVDBoneWeight

	func _to_string() -> String:
		return "VVDVertexData: position=%s, normal=%s, uv=%s, bone_weight=%s" % [position, normal, uv, bone_weight]

var header: VVDHeader;
var fixups: Array[VVDFixupTable] = [];
var vertices: Array[VVDVertexData] = [];
var tangents: Array[Plane] = [];
var file: FileAccess;

func done():
	if file: file.close();

func _init(file_path: String) -> void:
	file = FileAccess.open(file_path, FileAccess.READ);
	if file == null: 
		push_error("VVDReader: Can't open file %s" % file_path);
		return;

	header = ByteReader.read_by_structure(file, VVDHeader, VVDHeader.scheme);

	file.seek(header.fixup_table_offset);

	for i in range(header.num_fixups):
		var fixup = ByteReader.read_by_structure(file, VVDFixupTable, VVDFixupTable.scheme);
		fixups.append(fixup);

	file.seek(header.vertex_data_offset);

	for i in range(header.num_lods_vertexes[0]):
		var bone_weight = ByteReader.read_by_structure(file, VVDBoneWeight, VVDBoneWeight.scheme);
		var vertex_data = ByteReader.read_by_structure(file, VVDVertexData, VVDVertexData.scheme);

		vertex_data.bone_weight = bone_weight;
		vertices.append(vertex_data);

	file.seek(header.tangent_data_offset);

	for i in range(header.num_lods_vertexes[0]):
		tangents.append(ByteReader._read_data(file, ByteReader.Type.TANGENT));

	var copy_dist_index = 0;
	for fixup in fixups:
		fixup.dist_index = copy_dist_index;
		copy_dist_index += fixup.num_vertexes;

func find_vertex_index(vertex_id: int):
	for fixup in fixups:
		var idx = vertex_id - fixup.dist_index;

		if idx >= 0 and idx < fixup.num_vertexes:
			return fixup.source_vertex_id + idx;

	return vertex_id;
