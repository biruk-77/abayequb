// lib/data/models/kyc_model.dart
import 'package:json_annotation/json_annotation.dart';

part 'kyc_model.g.dart';

enum KYCStatus {
  @JsonValue('pending')
  pending,
  @JsonValue('verified')
  verified,
  @JsonValue('rejected')
  rejected,
  @JsonValue('expired')
  expired,
}

@JsonSerializable()
class KYCModel {
  final int? id;
  final int? userId;
  final String documentType;
  final String? documentUrl;
  final KYCStatus status;
  final String? reason;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  KYCModel({
    this.id,
    this.userId,
    required this.documentType,
    this.documentUrl,
    required this.status,
    this.reason,
    this.createdAt,
    this.updatedAt,
  });

  factory KYCModel.fromJson(Map<String, dynamic> json) =>
      _$KYCModelFromJson(json);
  Map<String, dynamic> toJson() => _$KYCModelToJson(this);
}
