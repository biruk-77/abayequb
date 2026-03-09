// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'receipt_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

ReceiptModel _$ReceiptModelFromJson(Map<String, dynamic> json) => ReceiptModel(
  id: (json['id'] as num?)?.toInt(),
  userId: (json['userId'] as num?)?.toInt(),
  receiptName: json['receiptName'] as String,
  amount: (json['amount'] as num).toDouble(),
  reason: json['reason'] as String,
  documentUrl: json['documentUrl'] as String?,
  status: $enumDecode(_$ReceiptStatusEnumMap, json['status']),
  adminReason: json['adminReason'] as String?,
  createdAt: json['createdAt'] == null
      ? null
      : DateTime.parse(json['createdAt'] as String),
  updatedAt: json['updatedAt'] == null
      ? null
      : DateTime.parse(json['updatedAt'] as String),
);

Map<String, dynamic> _$ReceiptModelToJson(ReceiptModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'userId': instance.userId,
      'receiptName': instance.receiptName,
      'amount': instance.amount,
      'reason': instance.reason,
      'documentUrl': instance.documentUrl,
      'status': _$ReceiptStatusEnumMap[instance.status]!,
      'adminReason': instance.adminReason,
      'createdAt': instance.createdAt?.toIso8601String(),
      'updatedAt': instance.updatedAt?.toIso8601String(),
    };

const _$ReceiptStatusEnumMap = {
  ReceiptStatus.pending: 'pending',
  ReceiptStatus.approved: 'approved',
  ReceiptStatus.rejected: 'rejected',
  ReceiptStatus.expired: 'expired',
};
