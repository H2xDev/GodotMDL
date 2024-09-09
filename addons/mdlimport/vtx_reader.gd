class_name VTXReader extends RefCounted

enum StripGroupFlag {
	FLEXED = 0x01,
	HWSKINNED = 0x02,
	DELTA_FLEXED = 0x04,
	SUPPRESS_HW_MORPH = 0x08,
}

class VTXHeader extends RefCounted:
	static var scheme:
		get: return {
		version 										= ByteReader.Type.INT,
		vertex_cache_size 								= ByteReader.Type.INT,
		max_bones_per_strip 							= ByteReader.Type.UNSIGNED_SHORT,
		max_bones_per_tri 								= ByteReader.Type.UNSIGNED_SHORT,
		max_bones_per_vertex 							= ByteReader.Type.INT,
		check_sum 										= ByteReader.Type.INT,
		num_lods 										= ByteReader.Type.INT,
		material_replacement_list_offset 				= ByteReader.Type.INT,
		num_body_parts 									= ByteReader.Type.INT,
		body_part_offset 								= ByteReader.Type.INT
	}

	var version: int = 0;
	var vertex_cache_size: int = 0;
	var max_bones_per_strip: int = 0;
	var max_bones_per_tri: int = 0;
	var max_bones_per_vertex: int = 0;
	var check_sum: int = 0;
	var num_lods: int = 0;
	var material_replacement_list_offset: int = 0;
	var num_body_parts: int = 0;
	var body_part_offset: int = 0;

	static var size:
		get: return 36;

	func _to_string() -> String:
		return "VTXHeader: {version: %d, vertex_cache_size: %d, max_bones_per_strip: %d, max_bones_per_tri: %d, max_bones_per_vertex: %d, check_sum: %d, num_lods: %d, material_replacement_list_offset: %d, num_body_parts: %d, body_part_offset: %d}" % [version, vertex_cache_size, max_bones_per_strip, max_bones_per_tri, max_bones_per_vertex, check_sum, num_lods, material_replacement_list_offset, num_body_parts, body_part_offset];

class VTXBodyPart extends RefCounted:
	static var scheme:
		get: return {
		num_models 										= ByteReader.Type.INT,
		model_offset 									= ByteReader.Type.INT,
	}

	static var size:
		get: return 8;

	var address = 0;
	var num_models: int;
	var model_offset: int;
	var models = [];

	func _to_string() -> String:
		return "VTXBodyPart: {num_models: %d, model_offset: %d}" % [num_models, model_offset];

class VTXModel extends RefCounted:
	static var scheme:
		get: return {
		num_lods 										= ByteReader.Type.INT,
		lod_offset 										= ByteReader.Type.INT,
	}

	var num_lods = 0;
	var lod_offset = 0;

	var address = 0;
	var lods = [];

	func _to_string() -> String:
		return "VTXModel: {num_lods: %d, lod_offset: %d}" % [num_lods, lod_offset];

class VTXLod extends RefCounted:
	static var scheme:
		get: return {
		num_meshes 										= ByteReader.Type.INT,
		mesh_offset 									= ByteReader.Type.INT,
		switch_point 									= ByteReader.Type.FLOAT,
	}

	static var size:
		get: return 12;

	var num_meshes: int = 0;
	var mesh_offset: int = 0;
	var switch_point: float;

	var address: int = 0;
	var meshes = [];

	func _to_string() -> String:
		return "VTXLod: {num_meshes: %d, mesh_offset: %d, switch_point: %f}" % [num_meshes, mesh_offset, switch_point];

class VTXMesh extends RefCounted:
	static var scheme:
		get: return {
		num_strip_groups 								= ByteReader.Type.INT,
		strip_group_offset 								= ByteReader.Type.INT,
		flags 											= ByteReader.Type.BYTE,
	}

	static var size: int:
		get: return 9;

	var num_strip_groups: int;
	var strip_group_offset: int;
	var flags: int;

	var address: int = 0;
	var idx_base: int = 0;
	var strip_groups: Array[VTXStripGroup] = [];

	func _to_string() -> String:
		return "VTXMesh: {num_strip_groups: %d, strip_group_offset: %d, flags: %d}" % [num_strip_groups, strip_group_offset, flags];

class VTXStripGroup extends RefCounted:
	static var scheme:
		get: return {
		num_verts 										= ByteReader.Type.INT,
		vert_offset 									= ByteReader.Type.INT,
		num_indices 									= ByteReader.Type.INT,
		index_offset 									= ByteReader.Type.INT,
		num_strips 									= ByteReader.Type.INT,
		strip_offset 									= ByteReader.Type.INT,
		flags 											= ByteReader.Type.BYTE,
	}

	static var size:
		get: return 17;

	var num_verts: int;
	var vert_offset: int;
	var num_indices: int;
	var index_offset: int;
	var num_strips: int;
	var strip_offset: int;
	var flags: StripGroupFlag;
	var unused: int;
	var unused2: int;

	var address: int = 0;
	var indices: Array[int] = [];
	var vertices: Array[VTXVertex] = [];
	var strips: Array[VTXStripHeader] = [];

	func _to_string() -> String:
		return "VTXStripGroup: {num_verts: %d, vert_offset: %d, num_indices: %d, index_offset: %d, num_strips: %d, strip_offset: %d, flags: %d, unused: %d, unused2: %d}" % [num_verts, vert_offset, num_indices, index_offset, num_strips, strip_offset, flags, unused, unused2];

class VTXStripHeader extends RefCounted:
	static var scheme:
		get: return {
		num_indices 									= ByteReader.Type.INT,
		index_offset 									= ByteReader.Type.INT,
		num_verts 										= ByteReader.Type.INT,
		vert_offset 									= ByteReader.Type.INT,
		num_bones 										= ByteReader.Type.SHORT,
		flags 											= ByteReader.Type.BYTE,
		num_bone_state_changes 							= ByteReader.Type.INT,
		bone_state_change_offset 						= ByteReader.Type.INT,
	}

	static var size:
		get: return 27;

	var num_indices: int;
	var index_offset: int;
	var num_verts: int;
	var vert_offset: int;
	var num_bones: int;
	var flags: int;
	var num_bone_state_changes: int;
	var bone_state_change_offset: int;
	var address: int = 0;

	func _to_string():
		return "VTXStripHeader: {num_indices: %d, index_offset: %d, num_verts: %d, vert_offset: %d, num_bones: %d, flags: %d, num_bone_state_changes: %d, bone_state_change_offset: %d}" % [num_indices, index_offset, num_verts, vert_offset, num_bones, flags, num_bone_state_changes, bone_state_change_offset];

class VTXVertex extends RefCounted:
	static var scheme:
		get: return {
		bone_weight_index 								= [ByteReader.Type.BYTE, 3],
		num_bones 										= ByteReader.Type.BYTE,
		orig_mesh_vert_id 								= ByteReader.Type.UNSIGNED_SHORT,
		bone_id 										= [ByteReader.Type.BYTE, 3],
	}

	var bone_weight_index: Array[int] = [];
	var num_bones: int;
	var orig_mesh_vert_id: int;
	var bone_id: Array[int] = [];

	func _to_string() -> String:
		return "VTXVertex: {bone_weight_index: %s, num_bones: %d, orig_mesh_vertID: %d, bone_id: %s}" % [bone_weight_index, num_bones, orig_mesh_vert_id, bone_id];

var header = {};
var body_parts = [];
var file: FileAccess;

func done():
	if file: file.close();

func _init(file_path: String) -> void:
	file = FileAccess.open(file_path, FileAccess.READ);

	if file == null:
		file = FileAccess.open(file_path.replace(".vtx", ".dx90.vtx"), FileAccess.READ);
		
		if file == null:
			push_error("Failed to open file: %s" % file_path);
			return;
	
	header = ByteReader.read_by_structure(file, VTXHeader, VTXHeader.scheme);

	_read_body_parts(header, file);

func _read_body_parts(header: VTXHeader, file: FileAccess):
	file.seek(header.body_part_offset);

	for i in range(header.num_body_parts):
		var address = file.get_position();
		var body_part = ByteReader.read_by_structure(file, VTXBodyPart, VTXBodyPart.scheme);
		body_part.address = address;

		body_parts.append(body_part);

	for body_part in body_parts:
		_read_models(body_part, file);

	return body_parts;

func _read_models(body_part: VTXBodyPart, file: FileAccess):
	file.seek(body_part.address + body_part.model_offset);

	for i in range(body_part.num_models):
		var address = file.get_position();
		var model = ByteReader.read_by_structure(file, VTXModel, VTXModel.scheme);
		model.address = address;

		body_part.models.append(model);

	for model in body_part.models:
		_read_lods(model, file);

func _read_lods(model: VTXModel, file: FileAccess):
	file.seek(model.address + model.lod_offset);

	for i in range(1):
		var address = file.get_position();
		var lod = ByteReader.read_by_structure(file, VTXLod, VTXLod.scheme);
		lod.address = address;

		model.lods.append(lod);
		
	for lod in model.lods:
		_read_mesh_headers(lod, file);

func _read_mesh_headers(lod: VTXLod, file: FileAccess):
	file.seek(lod.address + lod.mesh_offset);

	for i in range(lod.num_meshes):
		var address = file.get_position();
		var m = ByteReader.read_by_structure(file, VTXMesh, VTXMesh.scheme);
		m.address = address;
		lod.meshes.append(m);
	
	for mesh in lod.meshes:
		_read_strip_groups(mesh, file);

func _read_strip_groups(mesh: VTXMesh, file: FileAccess, debug = false):
	file.seek(mesh.address + mesh.strip_group_offset);

	for i in range(mesh.num_strip_groups):
		var address = file.get_position();
		var strip_group = ByteReader.read_by_structure(file, VTXStripGroup, VTXStripGroup.scheme);
		strip_group.address = address;
		mesh.strip_groups.append(strip_group);

	for strip_group in mesh.strip_groups:
		_read_vertices(strip_group, file);
		_read_indices(strip_group, mesh, file);
		_read_strip_headers(strip_group, file);

func _read_indices(strip_group: VTXStripGroup, mesh: VTXMesh, file: FileAccess):
	file.seek(strip_group.address + strip_group.index_offset);

	for j in range(strip_group.num_indices):
		strip_group.indices.append(mesh.idx_base + ByteReader._read_data(file, ByteReader.Type.UNSIGNED_SHORT));
	
	mesh.idx_base += strip_group.num_verts;

func _read_vertices(strip_group: VTXStripGroup, file: FileAccess):
	file.seek(strip_group.address + strip_group.vert_offset);

	for j in range(strip_group.num_verts):
		var vertex = ByteReader.read_by_structure(file, VTXVertex, VTXVertex.scheme);
		strip_group.vertices.append(vertex);

func _read_strip_headers(strip_group: VTXStripGroup, file: FileAccess):
	file.seek(strip_group.address + strip_group.strip_offset);

	for j in range(strip_group.num_strips):
		var strip_header = ByteReader.read_by_structure(file, VTXStripHeader, VTXStripHeader.scheme);
		strip_header.address = file.get_position() - VTXStripHeader.size;
		strip_group.strips.append(strip_header);
