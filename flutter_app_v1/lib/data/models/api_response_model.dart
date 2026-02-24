class ApiResponse<T> {
  final bool success;
  final String? message;
  final T? data;

  ApiResponse({required this.success, this.message, this.data});

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(dynamic)? fromJsonT,
  ) {
    return ApiResponse(
      success: json['success'] ?? true,
      message: json['message'],
      data: json['data'] != null && fromJsonT != null
          ? fromJsonT(json['data'])
          : json['data'],
    );
  }
}

class PaginatedResponse<T> {
  final List<T> content;
  final int totalElements;
  final int totalPages;
  final int number; // current page
  final int size;
  final bool first;
  final bool last;

  PaginatedResponse({
    required this.content,
    required this.totalElements,
    required this.totalPages,
    required this.number,
    required this.size,
    required this.first,
    required this.last,
  });

  factory PaginatedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) fromJsonT,
  ) {
    final content =
        (json['content'] as List?)
            ?.map((e) => fromJsonT(e as Map<String, dynamic>))
            .toList() ??
        [];
    return PaginatedResponse(
      content: content,
      totalElements: json['totalElements'] ?? 0,
      totalPages: json['totalPages'] ?? 0,
      number: json['number'] ?? 0,
      size: json['size'] ?? 10,
      first: json['first'] ?? true,
      last: json['last'] ?? true,
    );
  }
}
