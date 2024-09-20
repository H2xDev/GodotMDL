class_name VMTLoader extends RefCounted

static var default_shaders:
	get: return [
		'lightmappedgeneric'
	];

static var texture_mappings:
	get: return {
		basetexture = "albedo_texture",
		bumpmap = "normal_texture",
		detail = "detail_mask",
		roughnesstexture = "roughness_texture",
		metalnesstexture = "metallic_texture",
		ambientocclusiontexture = "ao_texture",
	};

static var feature_mappings:
	get: return {
		bumpmap = "normal_enabled",
		detail = "detail_enabled",
		ambientocclusiontexture = "ao_enabled",
	}

static var numberic_mappings:
	get: return {
		bumpmapscale = "normal_scale",
		roughnessfactor = "roughness",
		metallnessfactor = "metallic",
		specularfactor = "specular",
		ambientocclusionlightaffect = "ao_light_affect",
		detailblendmode = "detail_blend_mode",
	}

static func load(path: String):
	var structure = ValveFormatParser.parse(path, true);

	var shader_name = structure.keys()[0];
	var details = structure[shader_name];

	var material = StandardMaterial3D.new();

	for key in details.keys():
		key = key.replace('$', '');

		if key in texture_mappings:
			var material_key = texture_mappings[key];
			var texture_path = ("res://materials/" + str(details['$' + key])).replace('\\', '/') + ".vtf";

			if material_key in material:
				if ResourceLoader.exists(texture_path):
					material[material_key] = load(texture_path);

					if key in feature_mappings:
						material[feature_mappings[key]] = true;
			continue;

		if key in numberic_mappings:
			var material_key = numberic_mappings[key];
			material[material_key] = details['$' + key];
			continue;

	return material;
