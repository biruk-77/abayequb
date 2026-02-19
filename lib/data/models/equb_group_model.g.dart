// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'equb_group_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

EqubGroupModel _$EqubGroupModelFromJson(Map<String, dynamic> json) =>
    EqubGroupModel(
      id: asString(json['id']),
      name: asString(json['name']),
      packageId: asStringNonNull(json['packageId']),
      status: asString(json['status']),
      riskReserve: asDouble(json['riskReserve']),
      startDate: asDateTime(json['startDate']),
      currentCycle: asInt(json['currentCycle']),
      memberCount: asInt(json['memberCount']),
      totalCycles: asInt(json['totalCycles']),
      package: json['EqubPackage'] == null
          ? null
          : EqubPackageModel.fromJson(
              json['EqubPackage'] as Map<String, dynamic>,
            ),
      createdAt: asDateTime(json['createdAt']),
      updatedAt: asDateTime(json['updatedAt']),
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
