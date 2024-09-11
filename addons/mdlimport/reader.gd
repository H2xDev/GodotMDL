class_name ByteReader extends RefCounted

enum Type {
	INT 						= 1,
	STRING 						= 2,
	FLOAT 						= 3,
	UNSIGNED_SHORT 				= 4,
	UNSIGNED_CHAR 				= 5,
	CHAR 						= 6,
	BYTE 						= 7,
	VECTOR3 					= 8,
	VECTOR2 					= 9,
	TANGENT 					= 10,
	LONG 						= 11,
	SHORT 						= 12,
	STRING_NULL_TERMINATED 		= 13,
	QUATERNION 					= 14,
	MAT3X4 						= 15,
	EULER_VECTOR 				= 16
}

static func read_array(file: FileAccess, root_structure, offset_field: String, count_field: String, Clazz):
	var address = root_structure.address if "address" in root_structure else 0;
	var count = root_structure[count_field] if count_field in root_structure else 0;
	var offset = root_structure[offset_field] if offset_field in root_structure else 0;

	file.seek(address + offset);
	var result = [];

	for i in range(count):
		result.append(read_by_structure(file, Clazz));

	return result;

static func read_by_structure(file: FileAccess, Clazz, read_from = -1):
	var result = Clazz.new();

	if read_from > -1:
		file.seek(read_from);

	if "scheme" not in Clazz:
		push_error("ByteReader: Scheme not found in class: " + Clazz.name);
		return null;

	if "address" in result:
		result.address = file.get_position();

	for key in Clazz.scheme.keys():
		var type = Clazz.scheme[key];
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

	if "_on_read" in result:
		result._on_read();

	return result;

static func _read_data(file: FileAccess, type: Type):
	match type:
		Type.INT: 						return file.get_buffer(4).decode_s32(0);
		Type.STRING: 					return char(file.get_8());
		Type.FLOAT: 					return file.get_float();
		Type.SHORT: 					return file.get_buffer(2).decode_s16(0);
		Type.CHAR: 						return char(file.get_8());
		Type.BYTE: 						return file.get_8();
		Type.QUATERNION: 				return _read_quaternion(file);
		Type.VECTOR3: 					return _read_vector(file);
		Type.VECTOR2: 					return Vector2(file.get_float(), file.get_float());
		Type.TANGENT: 					return _convert_plane(Plane(file.get_float(), file.get_float(), file.get_float(), file.get_float()));
		Type.LONG: 						return file.get_buffer(8).decode_s64(0);
		Type.UNSIGNED_SHORT: 			return file.get_buffer(2).decode_u16(0);
		Type.UNSIGNED_CHAR: 			return file.get_buffer(1).decode_u8(0);
		Type.STRING_NULL_TERMINATED: 	return read_string(file);
		Type.MAT3X4: 					return _read_transform_3d(file);
		Type.EULER_VECTOR: 				return _read_euler_vector(file);
		_: return type;

## Matrix 3x4 to Transform3D
static func _read_transform_3d(file: FileAccess):
	var transform = Transform3D();
	var yup_transform = Transform3D(Vector3(1, 0, 0), Vector3(0, 0, 1), Vector3(0, -1, 0), Vector3(0, 0, 0));

	var x = Vector3(file.get_float(), file.get_float(), file.get_float());
	var y = Vector3(file.get_float(), file.get_float(), file.get_float());
	var z = Vector3(file.get_float(), file.get_float(), file.get_float());
	var t = Vector3(file.get_float(), file.get_float(), file.get_float());

	transform.basis = Basis(
		Vector3(x.x, x.y, x.z),
		Vector3(y.x, y.y, y.z),
		Vector3(z.x, z.y, z.z)
	);

	transform.origin = Vector3(t.x, t.y, t.z);

	return (transform * yup_transform).orthonormalized();

## Converts euler vector from z-up to y-up
static func _read_euler_vector(file: FileAccess):
	return Vector3(file.get_float(), file.get_float(), file.get_float());

## Converts plane from z-up to y-up
static func _convert_plane(plane: Plane):
	return Plane(plane.normal.x, plane.normal.z, plane.normal.y, plane.d);

static func _read_vector(file: FileAccess):
	var vector = Vector3(file.get_float(), file.get_float(), file.get_float());

	return Vector3(vector.x, vector.z, -vector.y);

static func _read_quaternion(file: FileAccess):
	var q = Quaternion(file.get_float(), file.get_float(), file.get_float(), file.get_float());

	# Convert quaternion from z-up to y-up
	return Quaternion(q.x, q.z, -q.y, q.w);

## Reads string of the file till null character
static func read_string(file: FileAccess, offset: int = -1):
	if offset > -1:
		file.seek(offset);

	var index = 0;
	var result = "";
	var char = file.get_8();

	while char != 0:
		result += char(char);
		char = file.get_8();
		index += 1;

		if index > 100: break;
	return result;

static func get_structure_string(name: String, class_instance, additional_fields = []):
	if "scheme" not in class_instance:
		push_error("ByteReader: Scheme not found in class: " + class_instance.name);
		return;

	var string = ""

	string += name + ": {\n";

	for field in additional_fields:
		string += "\t" + field + ": " + str(class_instance[field]) + ",\n";

	for key in class_instance.scheme.keys():
		string += "\t" + key + ": " + str(class_instance[key]) + ",\n";
	
	string += "}";

	return string;
	
