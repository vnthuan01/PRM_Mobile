class OtpResponse {
  final bool? success;
  final String? message;
  final int? expiresInSeconds;
  final int? remainingAttempts;
  final int? cooldownSeconds;

  OtpResponse({
    this.success,
    this.message,
    this.expiresInSeconds,
    this.remainingAttempts,
    this.cooldownSeconds,
  });

  factory OtpResponse.fromJson(Map<String, dynamic> json) {
    return OtpResponse(
      success: json['success'],
      message: json['message'],
      expiresInSeconds: json['expiresInSeconds'],
      remainingAttempts: json['remainingAttempts'],
      cooldownSeconds: json['cooldownSeconds'],
    );
  }
}
