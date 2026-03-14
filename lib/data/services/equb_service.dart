// lib/data/services/equb_service.dart
import 'package:dio/dio.dart';
import '../../core/utils/logger.dart';

class EqubService {
  final Dio _dio;

  EqubService(this._dio);

  // --- Packages ---

  Future<List<dynamic>> getPackages() async {
    try {
      final response = await _dio.get('/equb/packages');
      final data = response.data['data'];
      if (data is List) return data;
      if (data is Map && data['packages'] is List) return data['packages'];
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getPackageById(String id) async {
    try {
      final response = await _dio.get('/equb/packages/$id');
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  // --- Groups ---

  Future<List<dynamic>> getGroups({
    int page = 1,
    int limit = 20,
    String status = 'active',
    String sortBy = 'createdAt',
    String order = 'DESC',
  }) async {
    try {
      final response = await _dio.get(
        '/equb/groups',
        queryParameters: {
          'page': page,
          'limit': limit,
          'status': status,
          'sortBy': sortBy,
          'order': order,
        },
      );

      final data = response.data['data'];
      if (data is List) return data;
      if (data is Map && data['groups'] is List) return data['groups'];

      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getMyGroups() async {
    try {
      final response = await _dio.get('/equb/groups/my');
      final data = response.data['data'];
      if (data is List) return data;
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getGroupById(String id) async {
    try {
      final response = await _dio.get('/equb/groups/$id');
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createGroup(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/equb/groups', data: data);
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  // --- Members ---

  Future<List<dynamic>> getMembers() async {
    try {
      final response = await _dio.get('/equb/members');
      final data = response.data['data'];
      if (data is List) return data;
      if (data is Map && data['members'] is List) return data['members'];
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getMemberById(String id) async {
    try {
      final response = await _dio.get('/equb/members/$id');
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> joinGroup(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/equb/members', data: data);
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getGroupsByPackageId(String packageId) async {
    try {
      final response = await _dio.get(
        '/equb/groups',
        queryParameters: {'packageId': packageId},
      );
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getGroupsForPackage(String packageId) async {
    try {
      final response = await _dio.get('/equb/members/package/$packageId');
      final data = response.data['data'];
      if (data is List) return data;
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // --- Contributions ---

  Future<Map<String, dynamic>> makeContribution(
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await _dio.post('/equb/contributions', data: data);
      return response
          .data; // Returning full response might be better for status checks
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getNextContribution() async {
    try {
      final response = await _dio.get('/equb/contributions/next');
      final data = response.data['data'];
      if (data is List && data.isNotEmpty) {
        return Map<String, dynamic>.from(data.first);
      }
      return data is Map ? Map<String, dynamic>.from(data) : {};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getWallet() async {
    try {
      final response = await _dio.get('/equb/wallets');
      AppLogger.debug('RAW WALLET RESPONSE: ${response.data}');
      final data = response.data['data'];

      if (data is List) {
        if (data.isEmpty) {
          AppLogger.warning('Wallet data is an empty list');
          return {};
        }
        AppLogger.info('Wallet data is a list, taking first item');
        return Map<String, dynamic>.from(data.first);
      }

      return data ?? {};
    } catch (e) {
      AppLogger.error('API Error in getWallet', e);
      rethrow;
    }
  }

  Future<List<dynamic>> getTransactions({
    int page = 1,
    int limit = 10,
    String? type,
    String? status,
    String? method,
    double? minAmount,
    double? maxAmount,
    String? startDate,
    String? endDate,
    String sortBy = 'createdAt',
    String order = 'DESC',
  }) async {
    try {
      final Map<String, dynamic> query = {
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'order': order,
      };

      if (type != null) query['type'] = type;
      if (status != null) query['status'] = status;
      if (method != null) query['method'] = method;
      if (minAmount != null) query['minAmount'] = minAmount;
      if (maxAmount != null) query['maxAmount'] = maxAmount;
      if (startDate != null) query['startDate'] = startDate;
      if (endDate != null) query['endDate'] = endDate;

      final response = await _dio.get(
        '/equb/transactions',
        queryParameters: query,
      );
      final data = response.data['data'];
      if (data is List) return data;
      if (data is Map && data['transactions'] is List) {
        return data['transactions'];
      }
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getAllTransactions({
    int page = 1,
    int limit = 10,
    String? type,
    String? status,
    String? method,
    double? minAmount,
    double? maxAmount,
    String? startDate,
    String? endDate,
    String sortBy = 'createdAt',
    String order = 'DESC',
  }) async {
    try {
      final Map<String, dynamic> query = {
        'page': page,
        'limit': limit,
        'sortBy': sortBy,
        'order': order,
      };

      if (type != null) query['type'] = type;
      if (status != null) query['status'] = status;
      if (method != null) query['method'] = method;
      if (minAmount != null) query['minAmount'] = minAmount;
      if (maxAmount != null) query['maxAmount'] = maxAmount;
      if (startDate != null) query['startDate'] = startDate;
      if (endDate != null) query['endDate'] = endDate;

      final response = await _dio.get(
        '/equb/transactions/list',
        queryParameters: query,
      );
      final data = response.data['data'];
      if (data is List) return data;
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // --- Receipts / Wallet Top-up ---

  Future<Map<String, dynamic>> uploadReceipt({
    required String receiptName,
    required double amount,
    required String reason,
    required String filePath,
  }) async {
    try {
      final formData = FormData.fromMap({
        'receiptName': receiptName,
        'amount': amount,
        'reason': reason,
        'document': await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(RegExp(r'[/\\]')).last,
        ),
      });

      final response = await _dio.post('/equb/receipts', data: formData);
      return response.data;
    } catch (e) {
      AppLogger.error('Receipt Upload Error', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateReceipt(
    String id, {
    String? receiptName,
    double? amount,
    String? reason,
    String? filePath,
  }) async {
    try {
      final Map<String, dynamic> data = {};
      if (receiptName != null) data['receiptName'] = receiptName;
      if (amount != null) data['amount'] = amount;
      if (reason != null) data['reason'] = reason;

      if (filePath != null) {
        data['document'] = await MultipartFile.fromFile(
          filePath,
          filename: filePath.split(RegExp(r'[/\\]')).last,
        );
      }

      final formData = FormData.fromMap(data);
      final response = await _dio.put('/equb/receipts/$id', data: formData);
      return response.data;
    } catch (e) {
      AppLogger.error('Receipt Update Error', e);
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getTransactionById(String id) async {
    try {
      final response = await _dio.get('/equb/transactions/$id');
      return response.data['data'] ?? response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getMyReceipts() async {
    try {
      final response = await _dio.get('/equb/receipts/me');
      final data = response.data['data'];
      if (data is List) return data;
      return [];
    } catch (e) {
      AppLogger.error('Fetch My Receipts Error', e);
      rethrow;
    }
  }

  // --- New Features (v2) ---

  Future<Map<String, dynamic>> getNextPayout() async {
    try {
      final response = await _dio.get('/equb/contributions/next');
      final data = response.data['data'];
      if (data is List && data.isNotEmpty) {
        return Map<String, dynamic>.from(data.first);
      }
      return data is Map ? Map<String, dynamic>.from(data) : {};
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> requestWithdrawal(double amount) async {
    try {
      // Assuming endpoint from abay.json patterns
      final response = await _dio.post('/equb/wallets/withdraw', data: {'amount': amount});
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> submitDispute(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/equb/disputes', data: data);
      return response.data['data'];
    } catch (e) {
      rethrow;
    }
  }

  Future<List<dynamic>> getMyDisputes() async {
    try {
      final response = await _dio.get('/equb/disputes/me');
      final data = response.data['data'];
      if (data is List) return data;
      return [];
    } catch (e) {
      rethrow;
    }
  }

  // --- Bank Accounts (for Top-up) ---

  Future<List<dynamic>> getBankAccounts() async {
    try {
      final response = await _dio.get('/equb/accounts');
      final data = response.data['data'];
      if (data is List) return data;
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> updateBankAccount(String id, Map<String, dynamic> data) async {
    try {
      final response = await _dio.put('/equb/accounts/$id', data: data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> createBankAccount(Map<String, dynamic> data) async {
    try {
      final response = await _dio.post('/equb/accounts', data: data);
      return response.data['data'] ?? response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getBankAccountById(String id) async {
    try {
      final response = await _dio.get('/equb/accounts/$id');
      return response.data['data'] ?? response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteBankAccount(String id) async {
    try {
      await _dio.delete('/equb/accounts/$id');
    } catch (e) {
      rethrow;
    }
  }

  // --- Penalties ---

  Future<Map<String, dynamic>> createPenalty(String groupId) async {
    try {
      final response = await _dio.post('/equb/penalties', data: {'groupId': groupId});
      return response.data;
    } catch (e) {
      rethrow;
    }
  }

  // --- Revenues ---

  Future<List<dynamic>> getRevenues() async {
    try {
      final response = await _dio.get('/equb/revenues');
      final data = response.data['data'];
      if (data is List) return data;
      return [];
    } catch (e) {
      rethrow;
    }
  }

  Future<Map<String, dynamic>> getRevenueById(String id) async {
    try {
      final response = await _dio.get('/equb/revenues/$id');
      return response.data['data'] ?? response.data;
    } catch (e) {
      rethrow;
    }
  }

  Future<void> deleteRevenue(String id) async {
    try {
      await _dio.delete('/equb/revenues/$id');
    } catch (e) {
      rethrow;
    }
  }
}
