mixin JsonConvertible {
  Map<String, dynamic> toJson();

  static T fromJson<T>(
      Map<String, dynamic> json, T Function(Map<String, dynamic>) fromJson) {
    return fromJson(json);
  }

  static List<T> fromJsonList<T>(
      List<dynamic> jsonList, T Function(Map<String, dynamic>) fromJson) {
    return jsonList
        .map((json) => fromJson(json as Map<String, dynamic>))
        .toList();
  }
}
