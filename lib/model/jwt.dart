class JWT {
  final String accessToken;
  final String refreshToken;

  JWT({required this.accessToken, required this.refreshToken});

  factory JWT.fromJson(Map<String, dynamic> json) {
    return JWT(
      accessToken: json['accessToken'],
      refreshToken: json['refreshToken'],
    );
  }
}
