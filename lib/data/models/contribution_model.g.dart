// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'contribution_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ContributionModel _$ContributionModelFromJson(Map<String, dynamic> json) =>
    ContributionModel(
      id: asInt(json['id']),
      groupId: asInt(json['groupId']),
      userId: asInt(json['userId']),
      cycleNumber: asInt(json['cycleNumber']),
      amount: asDouble(json['amount']),
      dueDate: asDateTime(json['dueDate']),
      paidDate: asDateTime(json['paidDate']),
      status: asString(json['status']),
      transactionId: asInt(json['transactionId']),
      groupInfo: json['EqubGroup'] == null
          ? null
          : ContributionGroupInfo.fromJson(
              json['EqubGroup'] as Map<String, dynamic>,
            ),
      daysRemaining: asInt(json['daysRemaining']),
    );

Map<String, dynamic> _$ContributionModelToJson(ContributionModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'groupId': instance.groupId,
      'userId': instance.userId,
      'cycleNumber': instance.cycleNumber,
      'amount': instance.amount,
      'dueDate': instance.dueDate?.toIso8601String(),
      'paidDate': instance.paidDate?.toIso8601String(),
      'status': instance.status,
      'transactionId': instance.transactionId,
      'EqubGroup': instance.groupInfo,
      'daysRemaining': instance.daysRemaining,
    };

ContributionGroupInfo _$ContributionGroupInfoFromJson(
  Map<String, dynamic> json,
) => ContributionGroupInfo(id: asInt(json['id']), name: asString(json['name']));

Map<String, dynamic> _$ContributionGroupInfoToJson(
  ContributionGroupInfo instance,
) => <String, dynamic>{'id': instance.id, 'name': instance.name};
