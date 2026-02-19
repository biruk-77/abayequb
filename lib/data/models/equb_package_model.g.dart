// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equb_package_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EqubPackageModel _$EqubPackageModelFromJson(Map<String, dynamic> json) =>
    EqubPackageModel(
      id: asStringNonNull(json['id']),
      name: asString(json['name']),
      iconPath: asString(json['iconPath']),
      contributionAmount: asDouble(json['contributionAmount']),
      schedule: $enumDecodeNullable(_$EqubScheduleEnumMap, json['schedule']),
      groupSize: asInt(json['groupSize']),
      feePercentage: asDouble(json['feePercentage']),
      status:
          $enumDecodeNullable(_$EqubPackageStatusEnumMap, json['status']) ??
          EqubPackageStatus.active,
      targetAmount: asDouble(json['targetAmount']),
      currentRound: asInt(json['currentRound']),
    );

Map<String, dynamic> _$EqubPackageModelToJson(EqubPackageModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'iconPath': instance.iconPath,
      'contributionAmount': instance.contributionAmount,
      'schedule': _$EqubScheduleEnumMap[instance.schedule],
      'groupSize': instance.groupSize,
      'feePercentage': instance.feePercentage,
      'status': _$EqubPackageStatusEnumMap[instance.status],
      'targetAmount': instance.targetAmount,
      'currentRound': instance.currentRound,
    };

const _$EqubScheduleEnumMap = {
  EqubSchedule.daily: 'daily',
  EqubSchedule.weekly: 'weekly',
  EqubSchedule.monthly: 'monthly',
};

const _$EqubPackageStatusEnumMap = {
  EqubPackageStatus.active: 'active',
  EqubPackageStatus.completed: 'completed',
  EqubPackageStatus.pending: 'pending',
};
