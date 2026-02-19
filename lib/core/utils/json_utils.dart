class JsonUtils {
  // Keeping the class for namespace if needed, but defining top-level functions below
}

String? asString(dynamic value) {
  if (value == null) return null;
  return value.toString();
}

String asStringNonNull(dynamic value) {
  if (value == null) return '';
  return value.toString();
}

int? asInt(dynamic value) {
  if (value == null) return null;
  if (value is int) return value;
  if (value is num) return value.toInt();
  if (value is String) return int.tryParse(value);
  return null;
}

double? asDouble(dynamic value) {
  if (value == null) return null;
  if (value is double) return value;
  if (value is num) return value.toDouble();
  if (value is String) return double.tryParse(value);
  return null;
}

DateTime? asDateTime(dynamic value) {
  if (value == null) return null;
  if (value is DateTime) return value;
  if (value is String) return DateTime.tryParse(value);
  return null;
}
