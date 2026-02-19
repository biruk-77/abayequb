// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equb_member_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EqubMemberModel _$EqubMemberModelFromJson(Map<String, dynamic> json) =>
    EqubMemberModel(
      id: asString(json['id']),
      groupId: asStringNonNull(json['groupId']),
      userId: asStringNonNull(json['userId']),
      status: asString(json['status']),
      payoutOrder: asInt(json['payoutOrder']),
      joinedAt: asDateTime(json['joinedAt']),
    );

Map<String, dynamic> _$EqubMemberModelToJson(EqubMemberModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'userId': instance.userId,
      'status': instance.status,
      'payoutOrder': instance.payoutOrder,
      'joinedAt': instance.joinedAt?.toIso8601String(),
    };
