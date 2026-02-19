import '../../core/utils/json_utils.dart';

class TransactionModel {
  final int? id;
  final int? walletId;
  final String? type; // deposit, contribution, payout, withdrawal
  final double amount;
  final String? status; // completed, pending, failed
  final String? referenceId;
  final String? method;
  final String? description;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  TransactionModel({
    this.id,
    this.walletId,
    this.type,
    required this.amount,
    this.status,
    this.referenceId,
    this.method,
    this.description,
    this.createdAt,
    this.updatedAt,
  });

  bool get isContribution => type == 'contribution';
  bool get isDeposit => type == 'deposit';
  bool get isPayout => type == 'payout';
  bool get isWithdrawal => type == 'withdrawal';

  factory TransactionModel.fromJson(Map<String, dynamic> json) {
    return TransactionModel(
      id: asInt(json['id']),
      walletId: asInt(json['walletId']),
      type: asString(json['type']),
      amount: asDouble(json['amount']) ?? 0.0,
      status: asString(json['status']),
      referenceId: asString(json['referenceId']),
      method: asString(json['method']),
      description: asString(json['description']),
      createdAt: asDateTime(json['createdAt']),
      updatedAt: asDateTime(json['updatedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'walletId': walletId,
    'type': type,
    'amount': amount,
    'status': status,
    'referenceId': referenceId,
    'method': method,
    'description': description,
    'createdAt': createdAt?.toIso8601String(),
    'updatedAt': updatedAt?.toIso8601String(),
  };
}
