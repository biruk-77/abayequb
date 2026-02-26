// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equb_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EqubGroupModel _$EqubGroupModelFromJson(Map<String, dynamic> json) =>
    EqubGroupModel(
      id: JsonUtils.asString(json['id']),
      name: JsonUtils.asString(json['name']),
      packageId: JsonUtils.asStringNonNull(json['packageId']),
      status: JsonUtils.asString(json['status']),
      riskReserve: JsonUtils.asDouble(json['riskReserve']),
      startDate: JsonUtils.asDateTime(json['startDate']),
      currentCycle: JsonUtils.asInt(json['currentCycle']),
      memberCount: JsonUtils.asInt(json['memberCount']),
      totalCycles: JsonUtils.asInt(json['totalCycles']),
      package: json['EqubPackage'] == null
          ? null
          : EqubPackageModel.fromJson(
              json['EqubPackage'] as Map<String, dynamic>,
            ),
      createdAt: JsonUtils.asDateTime(json['createdAt']),
      updatedAt: JsonUtils.asDateTime(json['updatedAt']),
    );

Map<String, dynamic> _$EqubGroupModelToJson(EqubGroupModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'packageId': instance.packageId,
      'status': instance.status,
      'riskReserve': instance.riskReserve,
      'startDate': instance.startDate?.toIso8601String(),
      'currentCycle': instance.currentCycle,
      'memberCount': instance.memberCount,
      'totalCycles': instance.totalCycles,
      'EqubPackage': instance.package,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };
