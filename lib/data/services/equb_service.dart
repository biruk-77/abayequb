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
        return data.first;
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
      final response = await _dio.get(
        '/equb/transactions',
        queryParameters: {
          'page': page,
          'limit': limit,
          if (type != null) 'type': type,
          if (status != null) 'status': status,
          if (method != null) 'method': method,
          if (minAmount != null) 'minAmount': minAmount,
          if (maxAmount != null) 'maxAmount': maxAmount,
          if (startDate != null) 'startDate': startDate,
          if (endDate != null) 'endDate': endDate,
          'sortBy': sortBy,
          'order': order,
        },
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
}
