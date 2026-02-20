class JsonUtils {
  static String? asString(dynamic value) => value?.toString();

  static String asStringNonNull(dynamic value) => value?.toString() ?? '';

  static int? asInt(dynamic value) {
    if (value == null) return null;
    if (value is int) return value;
    if (value is String) return int.tryParse(value);
    if (value is double) return value.toInt();
    return null;
  }

  static double? asDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static DateTime? asDateTime(dynamic value) {
    if (value == null) return null;
    if (value is String) return DateTime.tryParse(value);
    return null;
  }

  static bool asBool(dynamic value) {
    if (value == null) return false;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) return value.toLowerCase() == 'true' || value == '1';
    return false;
  }
}

// Keep top-level for backward compatibility if needed, but class is safer for static analysis
String? asString(dynamic value) => JsonUtils.asString(value);
String asStringNonNull(dynamic value) => JsonUtils.asStringNonNull(value);
int? asInt(dynamic value) => JsonUtils.asInt(value);
double? asDouble(dynamic value) => JsonUtils.asDouble(value);
DateTime? asDateTime(dynamic value) => JsonUtils.asDateTime(value);
bool asBool(dynamic value) => JsonUtils.asBool(value);
