import 'package:json_annotation/json_annotation.dart';

part 'staff.g.dart';

@JsonSerializable()
class Staff {
  final String staffId;
  final String userId;
  final String fullName;
  final String email;
  final String phoneNumber;
  final String role;

  Staff({
    required this.staffId,
    required this.userId,
    required this.fullName,
    required this.email,
    required this.phoneNumber,
    required this.role,
  });

  factory Staff.fromJson(Map<String, dynamic> json) => _$StaffFromJson(json);
  Map<String, dynamic> toJson() => _$StaffToJson(this);
}
