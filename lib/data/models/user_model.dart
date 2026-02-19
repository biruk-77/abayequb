import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

enum UserType {
  @JsonValue('merchant')
  merchant,
  @JsonValue('farmer')
  farmer,
  @JsonValue('student')
  student,
  @JsonValue('diaspora')
  diaspora,
  @JsonValue('employee')
  employee,
}

@JsonSerializable()
class UserModel {
  @JsonKey(fromJson: _stringFromInt)
  final String id;
  final String fullName;
  @JsonKey(name: 'phone')
  final String phoneNumber;
  final String? email;
  @JsonKey(name: 'profile')
  final String? profileImage;
  @JsonKey(defaultValue: UserType.student)
  final UserType userType;
  @JsonKey(defaultValue: 0)
  final int trustScore;

  UserModel({
    required this.id,
    required this.fullName,
    required this.phoneNumber,
    this.email,
    this.profileImage,
    required this.userType,
    required this.trustScore,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);
  Map<String, dynamic> toJson() => _$UserModelToJson(this);
}

String _stringFromInt(dynamic value) => value.toString();
