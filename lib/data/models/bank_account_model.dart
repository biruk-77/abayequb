// lib/data/models/bank_account_model.dart

class BankAccountModel {
  final int id;
  final String bankName;
  final String accountName;
  final String accountNumber;
  final String? description;

  BankAccountModel({
    required this.id,
    required this.bankName,
    required this.accountName,
    required this.accountNumber,
    this.description,
  });

  factory BankAccountModel.fromJson(Map<String, dynamic> json) {
    return BankAccountModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      bankName: json['bankName'] ?? '',
      accountName: json['accountName'] ?? '',
      accountNumber: json['accountNumber'] ?? '',
      description: json['description'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'bankName': bankName,
      'accountName': accountName,
      'accountNumber': accountNumber,
      'description': description,
    };
  }
}
