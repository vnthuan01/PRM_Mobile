import 'package:json_annotation/json_annotation.dart';

part 'customer.g.dart';

@JsonSerializable()
class Customer {
  final String id;
  final String userId;
  final String? fullName;
  final String? email;
  final String? phoneNumber;
  final String? address;
  final String? status;
  final String? createdAt;
  final String? updatedAt;

  Customer({
    required this.id,
    required this.userId,
    this.fullName,
    this.email,
    this.phoneNumber,
    this.address,
    this.status,
    this.createdAt,
    this.updatedAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}
