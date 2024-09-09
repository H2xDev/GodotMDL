class_name MDLMeshGenerator extends RefCounted

static func generate_mesh(mdl: MDLReader, vtx: VTXReader, vvd: VVDReader):
	var mesh_instance = MeshInstance3D.new();
	var array_mesh = ArrayMesh.new();

	var _process_mesh = func(mesh: VTXReader.VTXMesh, body_part_index: int, model_index: int, mesh_index: int):
		var mdl_model = mdl.body_parts[body_part_index].models[model_index];
		var mdl_mesh = mdl_model.meshes[mesh_index];

		var model_vertex_index_start = mdl_model.vert_index / 0x30 | 0; # WTF?????

		for strip_group in mesh.strip_groups:
			var st = SurfaceTool.new();
	
			st.begin(Mesh.PRIMITIVE_TRIANGLES);
	
			for vert_info in strip_group.vertices:
				var vid = vvd.find_vertex_index(model_vertex_index_start + mdl_mesh.vertex_index_start + vert_info.orig_mesh_vert_id);
				var vert = vvd.vertices[vid];
				var tangent = vvd.tangents[vid];
	
				st.set_normal(_convert_vector(vert.normal));
				st.set_tangent(tangent);
				st.set_uv(vert.uv);
				st.add_vertex(_convert_vector(vert.position));
	
			for indice in strip_group.indices:
				st.add_index(indice);
	
			st.commit(array_mesh);

	var _process_lod = func(lod: VTXReader.VTXLod, body_part_index: int, model_index: int):
		var mesh_index = 0;
		for mesh in lod.meshes:
			_process_mesh.call(mesh, body_part_index, model_index, mesh_index);
			mesh_index += 1;

	var _process_model = func(model: VTXReader.VTXModel, body_part_index: int, model_index: int):
		# NOTE: Since godot doesn't support importing custom 
		# 		lod models, we will only use the first lod
		_process_lod.call(model.lods[0], body_part_index, model_index);

	var _process_body_part = func(body_part: VTXReader.VTXBodyPart, body_part_index: int):
		var model_index = 0;
		for model in body_part.models:
			_process_model.call(model, body_part_index, model_index);
			model_index += 1;

	var body_part_index = 0;
	for body_part in vtx.body_parts: 
		_process_body_part.call(body_part, body_part_index);
		body_part_index += 1;

	mesh_instance.set_mesh(array_mesh);

	return mesh_instance;

static func _convert_vector(v: Vector3) -> Vector3:
	return Vector3(v.x, v.z, -v.y);
