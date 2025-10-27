import 'package:json_annotation/json_annotation.dart';

part 'payment_response.g.dart';

@JsonSerializable()
class PaymentResponse {
  final bool? isSuccess;
  final String? message;
  final PaymentData? data;

  PaymentResponse({this.isSuccess, this.message, this.data});

  factory PaymentResponse.fromJson(Map<String, dynamic> json) =>
      _$PaymentResponseFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentResponseToJson(this);
}

@JsonSerializable()
class PaymentData {
  final PaymentLink? paymentLink;
  final String? paymentTransaction;

  PaymentData({this.paymentLink, this.paymentTransaction});

  factory PaymentData.fromJson(Map<String, dynamic> json) =>
      _$PaymentDataFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentDataToJson(this);
}

@JsonSerializable()
class PaymentLink {
  final String? bin;
  final String? accountNumber;
  final int? amount;
  final String? description;
  final int? orderCode;
  final String? currency;
  final String? paymentLinkId;
  final String? status;
  final String? expiredAt;
  final String? checkoutUrl;
  final String? qrCode;

  PaymentLink({
    this.bin,
    this.accountNumber,
    this.amount,
    this.description,
    this.orderCode,
    this.currency,
    this.paymentLinkId,
    this.status,
    this.expiredAt,
    this.checkoutUrl,
    this.qrCode,
  });

  factory PaymentLink.fromJson(Map<String, dynamic> json) =>
      _$PaymentLinkFromJson(json);

  Map<String, dynamic> toJson() => _$PaymentLinkToJson(this);
}
