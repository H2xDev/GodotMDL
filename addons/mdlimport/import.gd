@tool
class_name MDLImporter extends EditorImportPlugin

enum StripGroup {
	FLEXED = 0x01,
	HWSKINNED = 0x02,
	DELTA_FLEXED = 0x04,
	SUPPRESS_HW_MORPH = 0x08,
}

func _get_importer_name():
	return "MDL"

func _get_visible_name():
	return "MDL"

func _get_recognized_extensions():
	return ["mdl"];

func _get_save_extension():
	return "tscn";

func _get_resource_type():
	return "PackedScene";

func _get_priority():
	return 1;

func _get_preset_count() -> int:
	return 0;

func _get_import_order():
	return 1;

func _get_import_options(str, int):
	return [];

func _import(source_path, save_path, options, _platform_variants, _gen_files):
	var vtx_path = source_path.replace(".mdl", ".vtx");

	var phy_path = source_path.replace(".mdl", ".phy");
	var vvd_path = source_path.replace(".mdl", ".vvd");

	var mdl = MDLReader.new(source_path);
	var vtx = VTXReader.new(vtx_path);
	var vvd = VVDReader.new(vvd_path);
	var model_name = source_path.get_file().get_basename().replace(".mdl", "");

	if (!mdl or !vtx):
		push_error("Error while reading MDL or VTX file.");
		return false;

	# var phy = PHYReader.new(phy_path);

	var scn = PackedScene.new();
	var mesh_instance = MDLMeshGenerator.generate_mesh(mdl, vtx, vvd);
	
	mdl.done();
	vtx.done();
	vvd.done();

	mesh_instance.set_name(model_name);

	scn.pack(mesh_instance);

	var path_to_save = save_path + '.' + _get_save_extension();

	return ResourceSaver.save(scn, path_to_save);
