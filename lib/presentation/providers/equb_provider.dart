import 'package:flutter/foundation.dart';
import '../../data/models/equb_package_model.dart';
import '../../data/models/equb_group_model.dart';
import '../../data/repositories/equb_repository.dart';
import '../../data/models/equb_member_model.dart';
import '../../core/utils/logger.dart';
import '../../core/utils/network_error_handler.dart';

class EqubProvider extends ChangeNotifier {
  final EqubRepository _equbRepository;
  List<EqubPackageModel> _packages = [];
  List<EqubGroupModel> _groups = [];
  bool _isLoading = false;
  String? _error;

  EqubProvider(this._equbRepository);

  List<EqubGroupModel> _myGroups = [];
  List<EqubMemberModel> _myMemberships = [];
  List<EqubGroupModel> _packageGroups = [];

  List<EqubPackageModel> get packages => _packages;
  List<EqubGroupModel> get groups => _groups;
  List<EqubGroupModel> get myGroups => _myGroups;
  List<EqubMemberModel> get myMemberships => _myMemberships;
  List<EqubGroupModel> get packageGroups => _packageGroups;

  EqubGroupModel? _selectedGroupDetails;
  EqubGroupModel? get selectedGroupDetails => _selectedGroupDetails;

  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> fetchGroupsByPackage(String packageId) async {
    // 1. Check if we already have these groups in our general list to save a server hit
    final localMatches = _groups
        .where((g) => g.packageId == packageId)
        .toList();
    if (localMatches.isNotEmpty) {
      _packageGroups = localMatches;
      notifyListeners();
      AppLogger.info(
        'Provider: Found ${localMatches.length} groups locally for package $packageId',
      );
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info(
        'Provider: Fetching groups for package $packageId from API...',
      );
      _packageGroups = await _equbRepository.getGroupsByPackageId(packageId);

      // Merge into the main _groups list for persistence and UI visibility
      for (var group in _packageGroups) {
        if (!_groups.any((g) => g.id == group.id)) {
          _groups.add(group);
        }
      }

      if (_packageGroups.isEmpty) {
        AppLogger.warning(
          'Provider: No groups returned from API for package $packageId, trying local fallback',
        );
        if (_groups.isEmpty) {
          await fetchGroups();
        }
        _packageGroups = _groups
            .where((g) => g.packageId == packageId)
            .toList();
      }

      AppLogger.success(
        'Provider: Loaded ${_packageGroups.length} groups for package',
      );
    } catch (e) {
      AppLogger.error('Provider: Error fetching package groups', e);
      _error = e.toString();
      // local fallback on error too?
      if (_groups.isNotEmpty) {
        _packageGroups = _groups
            .where((g) => g.packageId == packageId)
            .toList();
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGroupDetails(String groupId) async {
    try {
      AppLogger.info('Provider: Fetching group details for $groupId...');
      _selectedGroupDetails = await _equbRepository.getGroupById(groupId);
      notifyListeners();
    } catch (e) {
      AppLogger.error('Provider: Error fetching group details', e);
    }
  }

  DateTime? _lastFetchTime;

  Future<void> fetchPackages({bool forceRefresh = false}) async {
    // 1. Loading guard
    if (_isLoading) return;

    // 2. Cache/Throttle guard: Don't hit server if data is fresh (within 5 mins) unless forced
    final isDataFresh =
        _lastFetchTime != null &&
        DateTime.now().difference(_lastFetchTime!).inMinutes < 5;

    if (!forceRefresh && _packages.isNotEmpty && isDataFresh) {
      AppLogger.info(
        'Provider: Using fresh cached data, skipping server hit for scalability.',
      );
      return;
    }

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // 1. Load from cache first if we have nothing in memory
      if (_packages.isEmpty) {
        final cachedPackages = await _equbRepository.getCachedPackages();
        if (cachedPackages.isNotEmpty) {
          _packages = cachedPackages;
          notifyListeners();
        }
      }

      // 2. Fetch from API
      AppLogger.info('Provider: Fetching eQub packages from server...');
      final apiPackages = await _equbRepository.getPackages();

      if (apiPackages.isNotEmpty) {
        _packages = apiPackages;
        await _equbRepository.cachePackages(apiPackages);
        _lastFetchTime = DateTime.now();
        AppLogger.success(
          'Provider: Fetched ${_packages.length} packages successfully',
        );
      }

      // NOTE: Removed aggressive background sync of all groups/memberships
      // to protect server at scale (1M+ users).
      // These will be fetched only when the user explicitly navigates to those sections.

      if (_packages.isEmpty) {
        AppLogger.warning('Provider: No packages found from API or Cache');
      }
    } catch (e) {
      AppLogger.error('Provider: Error fetching packages', e);
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> fetchGroups() async {
    try {
      // 1. Load from cache first
      final cachedGroups = await _equbRepository.getCachedGroups();
      if (cachedGroups.isNotEmpty) {
        _groups = cachedGroups;
        notifyListeners();
      }

      // 2. Fetch from API
      AppLogger.info('Provider: Fetching all eQub groups...');
      final apiGroups = await _equbRepository.getGroups(
        page: 1,
        limit: 10,
        status: 'active',
        sortBy: 'createdAt',
        order: 'DESC',
      );

      if (apiGroups.isNotEmpty) {
        _groups = apiGroups;
        await _equbRepository.cacheGroups(apiGroups);
        AppLogger.success(
          'Provider: Fetched ${_groups.length} available groups successfully',
        );
      } else {
        if (_groups.isEmpty) {
          AppLogger.warning('Provider: No available groups found');
        }
      }
    } catch (e) {
      AppLogger.error('Provider: Error fetching groups', e);
    } finally {
      notifyListeners();
    }
  }

  Future<void> fetchUserEqubData() async {
    try {
      // 1. Load from cache first
      final cachedMembers = await _equbRepository.getCachedMembers();
      if (cachedMembers.isNotEmpty) {
        _myMemberships = cachedMembers;
      }

      // 2. Fetch direct joined groups from API
      AppLogger.info('Provider: Fetching user joined groups directly...');
      final joinedGroups = await _equbRepository.getMyGroups();

      if (joinedGroups.isNotEmpty) {
        _myGroups = joinedGroups;
      }

      // 3. Fetch memberships for details like payout order
      final apiMembers = await _equbRepository.getMembers();

      if (apiMembers.isEmpty && _myMemberships.isEmpty) {
        AppLogger.warning('Provider: No memberships found');
        _myMemberships = [];
      } else {
        _myMemberships = apiMembers;
        AppLogger.info('Provider: User memberships data: $_myMemberships');
      }

      await _equbRepository.cacheMembers(_myMemberships);

      // Filter joined groups from memberships as fallback
      if (_myGroups.isEmpty && _myMemberships.isNotEmpty) {
        List<EqubGroupModel> sourceGroups = _groups;
        if (sourceGroups.isEmpty) {
          sourceGroups = await _equbRepository.getGroups();
        }

        _myGroups = sourceGroups
            .where(
              (g) => _myMemberships.any(
                (m) => m.groupId.toString() == g.id.toString(),
              ),
            )
            .toList();
      }

      AppLogger.success(
        'Provider: Fetched ${_myGroups.length} my groups and ${_myMemberships.length} memberships',
      );
      notifyListeners();
    } catch (e) {
      AppLogger.error('Provider: Error fetching user equb data', e);
    }
  }

  Future<EqubMemberModel?> joinGroup(String groupId) async {
    if (_isLoading) return null;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      AppLogger.info('Provider: Joining group $groupId...');
      final member = await _equbRepository.joinGroup(groupId);
      AppLogger.success('Provider: Successfully joined group!');

      // Refresh user data in background so UI isn't blocked by the sync
      fetchUserEqubData();
      return member;
    } catch (e) {
      AppLogger.error('Provider: Failed to join group', e);
      _error = NetworkErrorHandler.getUserFriendlyMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> contribute(String groupId) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // (FR-12.1 alignment: Membership should be handled via EnrollmentScreen before payment)

      AppLogger.info('Provider: Making contribution for group $groupId...');
      await _equbRepository.makeContribution(groupId);
      AppLogger.success('Provider: Contribution successful!');

      // Refresh wallet and dashboard data in background
      fetchUserEqubData();
    } catch (e) {
      AppLogger.error('Provider: Failed to make contribution', e);
      _error = NetworkErrorHandler.getUserFriendlyMessage(e);
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
