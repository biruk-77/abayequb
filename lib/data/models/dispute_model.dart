// lib/data/models/dispute_model.dart
import '../../core/utils/json_utils.dart';

class DisputeModel {
  final String id;
  final String? transactionId;
  final String category;
  final String description;
  final String status;
  final DateTime createdAt;

  DisputeModel({
    required this.id,
    this.transactionId,
    required this.category,
    required this.description,
    required this.status,
    required this.createdAt,
  });

  factory DisputeModel.fromJson(Map<String, dynamic> json) {
    return DisputeModel(
      id: JsonUtils.asString(json['id']) ?? '',
      transactionId: JsonUtils.asString(json['transactionId']),
      category: JsonUtils.asString(json['category']) ?? 'General',
      description: JsonUtils.asString(json['description']) ?? '',
      status: JsonUtils.asString(json['status']) ?? 'Pending',
      createdAt: JsonUtils.asDateTime(json['createdAt']) ?? DateTime.now(),
    );
  }
}
