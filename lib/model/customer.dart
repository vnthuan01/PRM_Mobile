import 'package:json_annotation/json_annotation.dart';

part 'customer.g.dart';

@JsonSerializable()
class Customer {
  final String id;
  final String userId;
  final String? address;
  final String? status;
  final String? createdAt;

  Customer({
    required this.id,
    required this.userId,
    this.address,
    this.status,
    this.createdAt,
  });

  factory Customer.fromJson(Map<String, dynamic> json) =>
      _$CustomerFromJson(json);
  Map<String, dynamic> toJson() => _$CustomerToJson(this);
}
