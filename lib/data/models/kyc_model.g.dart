// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'kyc_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

KYCModel _$KYCModelFromJson(Map<String, dynamic> json) => KYCModel(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  documentType: json['documentType'] as String,
  documentUrl: json['documentUrl'] as String?,
  status: $enumDecode(_$KYCStatusEnumMap, json['status']),
  reason: json['reason'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$KYCModelToJson(KYCModel instance) => <String, dynamic>{
  'id': instance.id,
  'userId': instance.userId,
  'documentType': instance.documentType,
  'documentUrl': instance.documentUrl,
  'status': _$KYCStatusEnumMap[instance.status]!,
  'reason': instance.reason,
  'createdAt': instance.createdAt?.toIso8601String(),
  'updatedAt': instance.updatedAt?.toIso8601String(),
};

const _$KYCStatusEnumMap = {
  KYCStatus.pending: 'pending',
  KYCStatus.verified: 'verified',
  KYCStatus.rejected: 'rejected',
  KYCStatus.expired: 'expired',
};
