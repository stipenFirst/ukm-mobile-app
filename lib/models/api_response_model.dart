class ApiResponseModel<T> {
  final String status;
  final String message;
  final T? data;

  const ApiResponseModel({
    required this.status,
    required this.message,
    this.data,
  });

  bool get isSuccess => status.toLowerCase() == 'success';

  factory ApiResponseModel.fromJson(
    Map<String, dynamic> json, {
    T Function(dynamic value)? parser,
  }) {
    return ApiResponseModel<T>(
      status: json['status']?.toString() ?? 'error',
      message: json['message']?.toString() ?? '',
      data: parser != null && json.containsKey('data') ? parser(json['data']) : json['data'] as T?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'status': status,
      'message': message,
      'data': data,
    };
  }
}
