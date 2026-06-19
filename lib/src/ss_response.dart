class SSResponse {
  final String status;
  final int? statusCode;
  final String? errorType;
  final String? errorMessage;

  const SSResponse({
    required this.status,
    this.statusCode,
    this.errorType,
    this.errorMessage,
  });

  bool get isSuccess => status.toLowerCase() == 'success';

  factory SSResponse.fromMap(Map<dynamic, dynamic>? map) {
    if (map == null) {
      return const SSResponse(status: 'success');
    }
    return SSResponse(
      status: (map['status'] as String?) ?? 'success',
      statusCode: (map['statusCode'] as num?)?.toInt(),
      errorType: map['errorType'] as String?,
      errorMessage: map['errorMessage'] as String?,
    );
  }

  @override
  String toString() => 'SSResponse(status: $status, statusCode: $statusCode, '
      'errorType: $errorType, errorMessage: $errorMessage)';
}
