class_name ByteReader extends RefCounted

## Returns data based on specified structure
##
## Structure example:
## {
## 	version = TYPE_INT,
## 	author = TYPE_STRING,
## 	created = TYPE_STRING,
## 	updated = TYPE_STRING,
## }

enum Type {
	INT = TYPE_INT,
	STRING = TYPE_STRING,
	FLOAT = TYPE_FLOAT,
	UNSIGNED_SHORT = 100,
	UNSIGNED_CHAR = 101,
	CHAR = 101,
	BYTE = 101,
	VECTOR3 = 102,
	VECTOR2 = 103,
	TANGENT = 104,
	LONG = 105,
	SHORT = 106,
	STRING_NULL_TERMINATED = 107,
	QUATERNION = 108,
	MAT3X4 = 109,
}

static func read_by_structure(file: FileAccess, Clazz, structure: Dictionary):
	var result = Clazz.new();

	for key in structure.keys():
		var type = structure[key];
		var elements_count = -1;

		if type is Array:
			elements_count = type[1];
			type = type[0];

		if not (key in result):
			print("Key not found: " + key);
			continue;

		if elements_count < 0:
			result[key] = _read_data(file, type);
		else:
			var buffer = "";
			for i in range(elements_count):
				if type != Type.STRING:
					result[key].append(_read_data(file, type));
				else:
					buffer += _read_data(file, type);

			if type == Type.STRING:
				result[key] = buffer;

	return result;

static func _read_data(file: FileAccess, type: Type):
		match type:
			Type.INT:
				return file.get_32();

			Type.STRING:
				return char(file.get_8());

			Type.FLOAT:
				return file.get_float();

			Type.SHORT:
				return file.get_16();

			Type.UNSIGNED_SHORT:
				return file.get_16();

			Type.UNSIGNED_CHAR:
				return file.get_8();

			Type.CHAR:
				return char(file.get_8());

			Type.BYTE:
				return file.get_8();

			Type.VECTOR3:
				return Vector3(file.get_float(), file.get_float(), file.get_float());

			Type.VECTOR2:
				return Vector2(file.get_float(), file.get_float());

			Type.TANGENT:
				return _convert_plane(Plane(file.get_float(), file.get_float(), file.get_float(), file.get_float()));

			Type.LONG:
				return file.get_64();

			Type.STRING_NULL_TERMINATED:
				return read_string(file);

			Type.QUATERNION:
				return Quaternion(file.get_float(), file.get_float(), file.get_float(), file.get_float());

			Type.MAT3X4:
				var transform = Transform3D();
				transform.basis = Basis(
					Vector3(file.get_float(), file.get_float(), file.get_float()),
					Vector3(file.get_float(), file.get_float(), file.get_float()),
					Vector3(file.get_float(), file.get_float(), file.get_float())
				);
				transform.origin = Vector3(file.get_float(), file.get_float(), file.get_float());

				return transform;
			_:
				return type;

## Converts plane from z-up to y-up
static func _convert_plane(plane: Plane):
	return Plane(plane.normal.x, plane.normal.z, plane.normal.y, plane.d);
	

## Reads string of the file till null character
static func read_string(file: FileAccess):
	var index = 0;
	var result = "";
	var char = file.get_8();

	while char != 0:
		result += char(char);
		char = file.get_8();
		index += 1;

		if index > 100: break;
	return result;
