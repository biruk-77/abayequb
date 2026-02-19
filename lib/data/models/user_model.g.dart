// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

UserModel _$UserModelFromJson(Map<String, dynamic> json) => UserModel(
  id: _stringFromInt(json['id']),
  fullName: json['fullName'] as String,
  phoneNumber: json['phone'] as String,
  email: json['email'] as String?,
  profileImage: json['profile'] as String?,
  userType:
      $enumDecodeNullable(_$UserTypeEnumMap, json['userType']) ??
      UserType.student,
  trustScore: (json['trustScore'] as num?)?.toInt() ?? 0,
);

Map<String, dynamic> _$UserModelToJson(UserModel instance) => <String, dynamic>{
  'id': instance.id,
  'fullName': instance.fullName,
  'phone': instance.phoneNumber,
  'email': instance.email,
  'profile': instance.profileImage,
  'userType': _$UserTypeEnumMap[instance.userType]!,
  'trustScore': instance.trustScore,
};

const _$UserTypeEnumMap = {
  UserType.merchant: 'merchant',
  UserType.farmer: 'farmer',
  UserType.student: 'student',
  UserType.diaspora: 'diaspora',
  UserType.employee: 'employee',
};
