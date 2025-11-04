class SendOtpRequest {
  final String email;
  final int purpose;

  SendOtpRequest({required this.email, required this.purpose});

  Map<String, dynamic> toJson() => {'email': email, 'purpose': purpose};
}

class VerifyOtpRequest {
  final String email;
  final String? otp;
  final int purpose;

  VerifyOtpRequest({required this.email, this.otp, required this.purpose});

  Map<String, dynamic> toJson() => {
    'email': email,
    'otp': otp,
    'purpose': purpose,
  };
}
