@tool
class_name VMTImporterPlugin extends EditorPlugin

var vmt_import_plugin;
var vtf_import_plugin;

func _enter_tree() -> void:
	vmt_import_plugin = preload("vmt_import.gd").new();
	vtf_import_plugin = preload("vtf_import.gd").new();

	add_import_plugin(vmt_import_plugin);
	add_import_plugin(vtf_import_plugin);

func _exit_tree() -> void:
	remove_import_plugin(vmt_import_plugin);
	remove_import_plugin(vtf_import_plugin);

	vmt_import_plugin = null;
	vtf_import_plugin = null;
