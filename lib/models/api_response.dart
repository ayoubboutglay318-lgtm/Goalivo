class ApiResponse<T> {
  const ApiResponse({
    required this.success,
    required this.data,
    required this.message,
  });

  final bool success;
  final T data;
  final String message;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic json) dataParser,
  ) {
    if (!json.containsKey('success')) {
      throw const FormatException('Response is missing "success" field.');
    }
    if (!json.containsKey('data')) {
      throw const FormatException('Response is missing "data" field.');
    }

    return ApiResponse<T>(
      success: json['success'] == true,
      data: dataParser(json['data']),
      message: json['message']?.toString() ?? '',
    );
  }
}
