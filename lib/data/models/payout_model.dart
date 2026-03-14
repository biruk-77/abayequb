// lib/data/models/payout_model.dart
import '../../core/utils/json_utils.dart';

class PayoutModel {
  final double amount;
  final DateTime payoutDate;
  final String groupName;

  PayoutModel({
    required this.amount,
    required this.payoutDate,
    required this.groupName,
  });

  factory PayoutModel.fromJson(Map<String, dynamic> json) {
    return PayoutModel(
      amount: JsonUtils.asDouble(json['amount']) ?? 0.0,
      payoutDate: JsonUtils.asDateTime(json['payoutDate']) ?? DateTime.now(),
      groupName: JsonUtils.asString(json['groupName']) ?? 'eQub Group',
    );
  }
}
