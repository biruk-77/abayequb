import '../services/equb_service.dart';
import '../models/equb_package_model.dart';
import '../models/equb_group_model.dart';
import '../models/equb_member_model.dart';
import '../models/wallet_model.dart';
import '../models/transaction_model.dart';
import '../../core/utils/logger.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class EqubRepository {
  final EqubService _equbService;

  EqubRepository(this._equbService);

  Future<List<EqubPackageModel>> getPackages() async {
    try {
      AppLogger.info('fetching all eQub packages...');
      final data = await _equbService.getPackages();
      final packages = data
          .map((json) => EqubPackageModel.fromJson(json))
          .toList();
      AppLogger.success('successfully loaded ${packages.length} packages');
      return packages;
    } catch (e) {
      AppLogger.error('failed to get packages', e);
      rethrow;
    }
  }

  Future<EqubPackageModel> getPackageById(String id) async {
    try {
      AppLogger.info('fetching package details for: $id');
      final data = await _equbService.getPackageById(id);
      final package = EqubPackageModel.fromJson(data);
      AppLogger.success('loaded package: ${package.name}');
      return package;
    } catch (e) {
      AppLogger.error('failed to get package by id: $id', e);
      rethrow;
    }
  }

  // Modified to use getGroupsByPackageId logic if needed, or keeping original getGroups
  // But user implies specific endpoint. I'll add the specific method and keep this one for now.
  Future<List<EqubGroupModel>> getGroups({
    int page = 1,
    int limit = 20,
    String status = 'active',
    String sortBy = 'createdAt',
    String order = 'DESC',
  }) async {
    try {
      AppLogger.info('fetching user eQub groups with status: $status...');
      final data = await _equbService.getGroups(
        page: page,
        limit: limit,
        status: status,
        sortBy: sortBy,
        order: order,
      );
      final groups = data.map((json) => EqubGroupModel.fromJson(json)).toList();
      AppLogger.success('found ${groups.length} active groups');
      return groups;
    } catch (e) {
      AppLogger.error('failed to get groups', e);
      rethrow;
    }
  }

  Future<List<EqubGroupModel>> getMyGroups() async {
    try {
      AppLogger.info('fetching user joined eQub groups...');
      final data = await _equbService.getMyGroups();
      final groups = data.map((json) => EqubGroupModel.fromJson(json)).toList();
      AppLogger.success('found ${groups.length} joined groups');
      return groups;
    } catch (e) {
      AppLogger.error('failed to get joined groups', e);
      rethrow;
    }
  }

  Future<List<EqubGroupModel>> getGroupsByPackageId(String packageId) async {
    try {
      AppLogger.info('fetching user eQub groups for package $packageId...');
      final data = await _equbService.getGroupsByPackageId(packageId);
      final groups = data.map((json) => EqubGroupModel.fromJson(json)).toList();
      return groups;
    } catch (e) {
      AppLogger.error('failed to get groups for package $packageId', e);
      rethrow;
    }
  }

  Future<List<EqubGroupModel>> getGroupsForPackage(String packageId) async {
    try {
      AppLogger.info(
        'fetching groups for package: $packageId using members-endpoint',
      );
      final data = await _equbService.getGroupsForPackage(packageId);
      final groups = data.map((json) => EqubGroupModel.fromJson(json)).toList();
      return groups;
    } catch (e) {
      AppLogger.error('failed to get groups for package $packageId', e);
      rethrow;
    }
  }

  Future<EqubGroupModel> getGroupById(String id) async {
    try {
      AppLogger.info('fetching group details for: $id');
      final data = await _equbService.getGroupById(id);
      final group = EqubGroupModel.fromJson(data);
      return group;
    } catch (e) {
      AppLogger.error('failed to get group by id: $id', e);
      rethrow;
    }
  }

  Future<EqubGroupModel> createGroup(EqubGroupModel group) async {
    try {
      AppLogger.info('creating new eQub group...');
      final data = await _equbService.createGroup(group.toJson());
      AppLogger.success('group created successfully');
      return EqubGroupModel.fromJson(data);
    } catch (e) {
      AppLogger.error('group creation failed', e);
      rethrow;
    }
  }

  Future<List<EqubMemberModel>> getMembers() async {
    try {
      AppLogger.info('fetching members list...');
      final data = await _equbService.getMembers();
      return data.map((json) => EqubMemberModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('failed to get members', e);
      rethrow;
    }
  }

  Future<EqubMemberModel> joinGroup(String groupId) async {
    try {
      AppLogger.info('joining group $groupId...');
      // Convert to int if possible to match backend expectations (per Postman tests)
      final numericId = int.tryParse(groupId) ?? groupId;
      final data = await _equbService.joinGroup({'groupId': numericId});
      AppLogger.success('successfully joined group');
      return EqubMemberModel.fromJson(data);
    } catch (e) {
      AppLogger.error('failed to join group', e);
      rethrow;
    }
  }

  Future<void> makeContribution(String groupId) async {
    try {
      AppLogger.info('making contribution for group $groupId...');
      // Convert to int if possible to match backend expectations (per Postman tests)
      final numericId = int.tryParse(groupId) ?? groupId;
      await _equbService.makeContribution({'groupId': numericId});
      AppLogger.success('contribution successful');
    } catch (e) {
      AppLogger.error('failed to make contribution', e);
      rethrow;
    }
  }

  Future<WalletModel> getWallet() async {
    try {
      AppLogger.info('fetching wallet info...');
      final data = await _equbService.getWallet();
      final wallet = WalletModel.fromJson(data);
      AppLogger.success(
        'Successfully parsed wallet: available=${wallet.available}, locked=${wallet.locked}',
      );
      return wallet;
    } catch (e) {
      AppLogger.error('failed to get wallet info', e);
      rethrow;
    }
  }

  // --- Caching Methods ---

  Future<void> cachePackages(List<EqubPackageModel> packages) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = packages.map((p) => p.toJson()).toList();
      await prefs.setString('cached_packages', jsonEncode(jsonList));
    } catch (e) {
      AppLogger.error('Failed to cache packages', e);
    }
  }

  Future<List<EqubPackageModel>> getCachedPackages() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_packages');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => EqubPackageModel.fromJson(json)).toList();
      }
    } catch (e) {
      AppLogger.error('Failed to load cached packages', e);
    }
    return [];
  }

  Future<void> cacheGroups(List<EqubGroupModel> groups) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = groups.map((g) => g.toJson()).toList();
      await prefs.setString('cached_groups', jsonEncode(jsonList));
    } catch (e) {
      AppLogger.error('Failed to cache groups', e);
    }
  }

  Future<List<EqubGroupModel>> getCachedGroups() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_groups');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => EqubGroupModel.fromJson(json)).toList();
      }
    } catch (e) {
      AppLogger.error('Failed to load cached groups', e);
    }
    return [];
  }

  Future<void> cacheMembers(List<EqubMemberModel> members) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonList = members.map((m) => m.toJson()).toList();
      await prefs.setString('cached_members', jsonEncode(jsonList));
    } catch (e) {
      AppLogger.error('Failed to cache members', e);
    }
  }

  Future<List<EqubMemberModel>> getCachedMembers() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_members');
      if (jsonString != null) {
        final List<dynamic> jsonList = jsonDecode(jsonString);
        return jsonList.map((json) => EqubMemberModel.fromJson(json)).toList();
      }
    } catch (e) {
      AppLogger.error('Failed to load cached members', e);
    }
    return [];
  }

  Future<void> cacheWallet(WalletModel wallet) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_wallet', jsonEncode(wallet.toJson()));
    } catch (e) {
      AppLogger.error('Failed to cache wallet', e);
    }
  }

  Future<WalletModel?> getCachedWallet() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonString = prefs.getString('cached_wallet');
      if (jsonString != null) {
        return WalletModel.fromJson(jsonDecode(jsonString));
      }
    } catch (e) {
      AppLogger.error('Failed to load cached wallet', e);
    }
    return null;
  }

  Future<List<TransactionModel>> getTransactions({
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
      AppLogger.info('fetching transactions...');
      final data = await _equbService.getTransactions(
        page: page,
        limit: limit,
        type: type,
        status: status,
        method: method,
        minAmount: minAmount,
        maxAmount: maxAmount,
        startDate: startDate,
        endDate: endDate,
        sortBy: sortBy,
        order: order,
      );
      return data.map((json) => TransactionModel.fromJson(json)).toList();
    } catch (e) {
      AppLogger.error('failed to get transactions', e);
      rethrow;
    }
  }
}
