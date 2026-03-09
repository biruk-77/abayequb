// lib/data/models/receipt_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'receipt_model.g.dart';

enum ReceiptStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('approved')
  approved,
  @JsonValue('rejected')
  rejected,
  @JsonValue('expired')
  expired,
}

@JsonSerializable()
class ReceiptModel {
  final int? id;
  final int? userId;
  final String receiptName; // CBE, Telebirr, etc.
  final double amount;
  final String reason;
  final String? documentUrl;
  final ReceiptStatus status;
  final String? adminReason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  ReceiptModel({
    this.id,
    this.userId,
    required this.receiptName,
    required this.amount,
    required this.reason,
    this.documentUrl,
    required this.status,
    this.adminReason,
    this.createdAt,
    this.updatedAt,
  });

  factory ReceiptModel.fromJson(Map<String, dynamic> json) =>
      _$ReceiptModelFromJson(json);
  Map<String, dynamic> toJson() => _$ReceiptModelToJson(this);
}
