import '../../core/utils/json_utils.dart';

class WalletModel {
  final int? id;
  final int? userId;
  final double? availableBalance;
  final double? lockedBalance;
  final String currency;

  WalletModel({
    this.id,
    this.userId,
    this.availableBalance,
    this.lockedBalance,
    this.currency = 'ETB',
  });

  double get available => availableBalance ?? 0.0;
  double get locked => lockedBalance ?? 0.0;
  double get totalAssets => (availableBalance ?? 0.0) + (lockedBalance ?? 0.0);

  factory WalletModel.fromJson(Map<String, dynamic> json) {
    return WalletModel(
      id: asInt(json['id']),
      userId: asInt(json['userId']),
      availableBalance: asDouble(json['balance']),
      lockedBalance: asDouble(json['lockedBalance']),
      currency: asString(json['currency']) ?? 'ETB',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'userId': userId,
    'balance': availableBalance,
    'lockedBalance': lockedBalance,
    'currency': currency,
  };
}
