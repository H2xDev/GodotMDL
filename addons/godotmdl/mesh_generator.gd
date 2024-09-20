class_name MDLMeshGenerator extends RefCounted

static func generate_mesh(mdl: MDLReader, vtx: VTXReader, vvd: VVDReader, options: Dictionary) -> MeshInstance3D:
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
	
				st.set_normal(vert.normal);
				st.set_tangent(tangent);
				st.set_uv(vert.uv);
				st.set_bones(vert.bone_weight.bone_bytes);
				st.set_weights(vert.bone_weight.weight_bytes);
				st.add_vertex(vert.position * options.scale);
	
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

	
	_assign_materials(array_mesh, mdl);

	var skeleton = _generate_skeleton(mdl, options)
	var skin = skeleton.create_skin_from_rest_transforms();

	skeleton.name = "skeleton";
	mesh_instance.add_child(skeleton);
	skeleton.set_owner(mesh_instance);

	mesh_instance.set_skeleton_path("skeleton");
	mesh_instance.set_skin(skin);
	mesh_instance.set_mesh(array_mesh);

	return mesh_instance;

static func _generate_skeleton(mdl: MDLReader, options: Dictionary) -> Skeleton3D:
	var skeleton = Skeleton3D.new();

	for bone in mdl.bones:
		skeleton.add_bone(bone.name);

	for bone in mdl.bones:
		if bone.parent != -1:
			skeleton.set_bone_parent(bone.id, bone.parent);

		var parent_bone = mdl.bones[bone.parent];
		var parent_transform = parent_bone.pos_to_bone if parent_bone else Transform3D.IDENTITY;
		var target_transform = bone.pos_to_bone * parent_transform;
		var additional_rotation = Basis.from_euler(bone.rot);
		var transform = Transform3D(Basis(bone.quat), bone.pos * options.scale);

		skeleton.set_bone_global_pose_override(bone.id, target_transform, 1.0);
		skeleton.set_bone_pose_position(bone.id, transform.origin);
		skeleton.set_bone_pose_rotation(bone.id, transform.basis.get_rotation_quaternion());

		var target_rest_pose = skeleton.get_bone_pose(bone.id);

		skeleton.set_bone_rest(bone.id, target_rest_pose);
		skeleton.reset_bone_pose(bone.id);

	return skeleton;

static func _assign_materials(mesh: ArrayMesh, mdl: MDLReader):
	print(mdl.textureDirs);
	pass;

static func _convert_vector(v: Vector3) -> Vector3:
	return Vector3(v.x, v.z, -v.y);
