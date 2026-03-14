// lib/presentation/providers/wallet_provider.dart
import 'package:flutter/foundation.dart';
import '../../data/models/wallet_model.dart';
import '../../data/models/transaction_model.dart';
import '../../core/utils/logger.dart';
import '../../data/repositories/equb_repository.dart';

class WalletProvider extends ChangeNotifier {
  final EqubRepository _repository;
  WalletModel? _wallet;
  bool _isLoading = false;
  List<TransactionModel> _transactions = [];
  bool _isTransactionsLoading = false;

  WalletProvider(this._repository);

  bool _isBalanceVisible = true;

  WalletModel? get wallet => _wallet;
  bool get isLoading => _isLoading;
  bool get isBalanceVisible => _isBalanceVisible;
  List<TransactionModel> get transactions => _transactions;
  bool get isTransactionsLoading => _isTransactionsLoading;

  void _safeNotify() {
    Future.microtask(() => notifyListeners());
  }

  void toggleBalanceVisibility() {
    _isBalanceVisible = !_isBalanceVisible;
    notifyListeners();
  }

  void clearData() {
    _wallet = null;
    _transactions = [];
    _isLoading = false;
    _isTransactionsLoading = false;
    _safeNotify();
    AppLogger.info('Provider: Wallet data cleared');
  }

  Future<void> fetchWallet() async {
    if (_isLoading) return;
    _isLoading = true;
    _safeNotify();

    try {
      AppLogger.info('Provider: Fetching wallet balance...');
      _wallet = await _repository.getWallet();
      AppLogger.success(
        'Provider: Wallet state updated. Available: ${_wallet?.available}, Locked: ${_wallet?.locked}',
      );
    } catch (e) {
      AppLogger.error('Provider: Error fetching wallet', e);
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }

  Future<void> makePayment(double amount) async {
    if (_wallet == null) return;
    if (amount > _wallet!.available) {
      AppLogger.warning('Provider: Insufficient funds for payment of $amount');
      throw Exception('Insufficient funds');
    }

    try {
      AppLogger.info('Provider: Making payment of $amount...');
      // Local simulation after success
      await Future.delayed(const Duration(seconds: 1));

      _wallet = WalletModel(
        id: _wallet!.id,
        userId: _wallet!.userId,
        availableBalance: _wallet!.available - amount,
        lockedBalance: _wallet!.locked + amount,
        currency: _wallet!.currency,
      );

      AppLogger.success(
        'Provider: Payment simulated. New available: ${_wallet!.available}',
      );
      notifyListeners();
    } catch (e) {
      AppLogger.error('Provider: Payment failed', e);
      rethrow;
    }
  }

  Future<void> fetchTransactions({
    int page = 1,
    int limit = 20,
    String? type,
    String? status,
    String? method,
  }) async {
    _isTransactionsLoading = true;
    _safeNotify();

    try {
      AppLogger.info('Provider: Fetching transactions...');
      _transactions = await _repository.getTransactions(
        page: page,
        limit: limit,
        type: type,
        status: status,
        method: method,
      );
      AppLogger.success(
        'Provider: Fetched ${_transactions.length} transactions',
      );
    } catch (e) {
      AppLogger.error('Provider: Error fetching transactions', e);
    } finally {
      _isTransactionsLoading = false;
      _safeNotify();
    }
  }

  // --- Receipts ---

  Future<void> uploadReceipt({
    required String receiptName,
    required double amount,
    required String reason,
    required String filePath,
  }) async {
    _isLoading = true;
    _safeNotify();

    try {
      AppLogger.info('Provider: Uploading receipt...');
      await _repository.uploadReceipt(
        receiptName: receiptName,
        amount: amount,
        reason: reason,
        filePath: filePath,
      );
      AppLogger.success('Provider: Receipt uploaded successfully');

      // Refresh transactions to show the new pending top-up
      await fetchTransactions();
    } catch (e) {
      AppLogger.error('Provider: Receipt upload failed', e);
      rethrow;
    } finally {
      _isLoading = false;
      _safeNotify();
    }
  }
}
