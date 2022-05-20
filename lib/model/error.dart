class KasError {
  int code;
  String message;
  String requestId;

  KasError({
    required this.code,
    required this.message,
    required this.requestId,
  });

  factory KasError.fromJson(Map<String, dynamic> json) {
    return KasError(
      code: json['code'],
      message: json['message'],
      requestId: json['requestId'],
    );
  }
}
