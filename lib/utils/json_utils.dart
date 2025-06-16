class JsonUtils {
  static DateTime parseDateTime(dynamic value, {DateTime? defaultValue}) {
    if (value == null) return defaultValue ?? DateTime.now();
    if (value is DateTime) return value;
    try {
      return DateTime.parse(value.toString());
    } catch (e) {
      return defaultValue ?? DateTime.now();
    }
  }

  static String parseString(dynamic value, {String defaultValue = ''}) {
    if (value == null) return defaultValue;
    return value.toString();
  }

  static int parseInt(dynamic value, {int defaultValue = 0}) {
    if (value == null) return defaultValue;
    if (value is int) return value;
    return int.tryParse(value.toString()) ?? defaultValue;
  }

  static bool parseBool(dynamic value, {bool defaultValue = false}) {
    if (value == null) return defaultValue;
    if (value is bool) return value;
    if (value is int) return value == 1;
    if (value is String) {
      return value.toLowerCase() == 'true' || value == '1';
    }
    return defaultValue;
  }

  static String? parseNullableString(dynamic value) {
    if (value == null) return null;
    final str = value.toString();
    return str.isEmpty ? null : str;
  }

  static Map<String, dynamic> parseMap(dynamic value, {Map<String, dynamic> defaultValue = const {}}) {
    if (value == null) return defaultValue;
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return defaultValue;
  }

  static List<T> parseList<T>(dynamic value, T Function(dynamic) parser, {List<T> defaultValue = const []}) {
    if (value == null) return defaultValue;
    if (value is List) {
      return value.map(parser).toList();
    }
    return defaultValue;
  }
} 