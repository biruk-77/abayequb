import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../data/models/equb_package_model.dart';
import '../../data/models/equb_group_model.dart';
import '../providers/equb_provider.dart';
import '../../core/utils/currency_formatter.dart';
import '../../core/utils/date_formatter.dart';

class ContributionLevelScreen extends StatefulWidget {
  final EqubPackageModel package;
  final String? initialGroupId;

  const ContributionLevelScreen({
    super.key,
    required this.package,
    this.initialGroupId,
  });

  @override
  State<ContributionLevelScreen> createState() =>
      _ContributionLevelScreenState();
}

class _ContributionLevelScreenState extends State<ContributionLevelScreen> {
  int _selectedGroupIndex = -1;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await context.read<EqubProvider>().fetchGroupsByPackage(
        widget.package.id,
      );

      // Auto-select if initialGroupId is provided
      if (widget.initialGroupId != null && mounted) {
        final groups = context.read<EqubProvider>().packageGroups;
        final index = groups.indexWhere((g) => g.id == widget.initialGroupId);
        if (index != -1) {
          setState(() => _selectedGroupIndex = index);
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Stack(
        children: [
          // Background Header Curve
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 250,
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Theme.of(context).primaryColor,
                    Theme.of(context).primaryColor.withOpacity(0.8),
                  ],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ),
                borderRadius: const BorderRadius.vertical(
                  bottom: Radius.elliptical(300, 50),
                ),
              ),
            ),
          ),

          Column(
            children: [
              AppBar(
                backgroundColor: Colors.transparent,
                elevation: 0,
                leading: IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.white),
                  onPressed: () => context.pop(),
                ),
                title: const Column(
                  children: [
                    Text(
                      'ABAY eQUB',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      'Flowing Wealth, Shared Future',
                      style: TextStyle(fontSize: 10, color: Colors.white70),
                    ),
                  ],
                ),
                centerTitle: true,
                actions: const [
                  Padding(
                    padding: EdgeInsets.only(right: 16.0),
                    child: CircleAvatar(
                      backgroundImage: NetworkImage(
                        'https://randomuser.me/api/portraits/women/44.jpg',
                      ),
                      radius: 18,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 20),
              const Text(
                'Select Contribution Level',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 60), // Space for curve

              Expanded(
                child: Consumer<EqubProvider>(
                  builder: (context, provider, child) {
                    if (provider.isLoading) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    final groups = provider.packageGroups;

                    if (groups.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.group_off,
                              size: 64,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'No groups available for this package',
                              style: TextStyle(color: Colors.grey[600]),
                            ),
                          ],
                        ),
                      );
                    }

                    // Get current group if selected
                    final selectedGroup = _selectedGroupIndex != -1
                        ? groups[_selectedGroupIndex]
                        : null;

                    return SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 10),
                          SizedBox(
                            height: 140,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 16,
                              ),
                              itemCount: groups.length,
                              itemBuilder: (context, index) {
                                final group = groups[index];
                                final isSelected = _selectedGroupIndex == index;
                                final isCompleted =
                                    group.status?.toLowerCase() == 'completed';

                                return GestureDetector(
                                  onTap: () => setState(
                                    () => _selectedGroupIndex = index,
                                  ),
                                  child: Stack(
                                    children: [
                                      AnimatedContainer(
                                        duration: const Duration(
                                          milliseconds: 300,
                                        ),
                                        width: 100,
                                        margin: const EdgeInsets.only(
                                          right: 12,
                                          bottom: 8,
                                          top: 8,
                                        ),
                                        decoration: BoxDecoration(
                                          color: isSelected
                                              ? Theme.of(
                                                  context,
                                                ).primaryColor.withOpacity(0.05)
                                              : Colors.white,
                                          borderRadius: BorderRadius.circular(
                                            20,
                                          ),
                                          border: Border.all(
                                            color: isSelected
                                                ? Theme.of(context).primaryColor
                                                : Colors.grey.withOpacity(0.2),
                                            width: isSelected ? 2 : 1,
                                          ),
                                          boxShadow: isSelected
                                              ? [
                                                  BoxShadow(
                                                    color: Theme.of(context)
                                                        .primaryColor
                                                        .withOpacity(0.1),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 4),
                                                  ),
                                                ]
                                              : null,
                                        ),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Icon(
                                              Icons.groups_rounded,
                                              color: isSelected
                                                  ? Theme.of(
                                                      context,
                                                    ).primaryColor
                                                  : (isCompleted
                                                        ? Colors.grey
                                                        : Colors.blueGrey),
                                              size: 32,
                                            ),
                                            const SizedBox(height: 8),
                                            Text(
                                              group.name ?? 'Group',
                                              style: TextStyle(
                                                fontWeight: isSelected
                                                    ? FontWeight.bold
                                                    : FontWeight.normal,
                                                fontSize: 11,
                                                color: isSelected
                                                    ? Theme.of(
                                                        context,
                                                      ).primaryColor
                                                    : Colors.black87,
                                              ),
                                              textAlign: TextAlign.center,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ],
                                        ),
                                      ),
                                      if (isCompleted)
                                        Positioned(
                                          top: 14,
                                          right: 20,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.grey,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        )
                                      else
                                        Positioned(
                                          top: 14,
                                          right: 20,
                                          child: Container(
                                            width: 8,
                                            height: 8,
                                            decoration: const BoxDecoration(
                                              color: Colors.green,
                                              shape: BoxShape.circle,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            ),
                          ),

                          if (selectedGroup != null) ...[
                            const SizedBox(height: 20),
                            _buildEnhancedGroupInfo(selectedGroup),
                            const SizedBox(height: 40),
                          ],
                        ],
                      ),
                    );
                  },
                ),
              ),

              // Bottom Button
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withOpacity(0.1),
                      Theme.of(
                        context,
                      ).scaffoldBackgroundColor.withOpacity(0.0),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
                child: SizedBox(
                  height: 56,
                  child: Consumer<EqubProvider>(
                    builder: (context, provider, child) {
                      final isSelected = _selectedGroupIndex != -1;
                      bool isJoined = false;
                      EqubGroupModel? selectedGroup;

                      if (isSelected) {
                        selectedGroup =
                            provider.packageGroups[_selectedGroupIndex];
                        // Check membership against actual enrollments
                        isJoined = provider.myMemberships.any(
                          (m) =>
                              m.groupId.toString() ==
                              selectedGroup?.id.toString(),
                        );
                      }

                      final isCompleted =
                          selectedGroup?.status?.toLowerCase() == 'completed';

                      return ElevatedButton(
                        onPressed:
                            isSelected && !provider.isLoading && !isCompleted
                            ? () async {
                                if (isJoined) {
                                  context.push(
                                    '/payment',
                                    extra: {
                                      'amount':
                                          (widget.package.contributionAmount ??
                                                  0)
                                              .toDouble(),
                                      'packageName': widget.package.name,
                                      'groupId': selectedGroup?.id,
                                    },
                                  );
                                } else {
                                  // Go to enrollment screen first
                                  final result = await context.push<bool>(
                                    '/enrollment',
                                    extra: {
                                      'group': selectedGroup,
                                      'package': widget.package,
                                    },
                                  );
                                  if (result == true) {
                                    // Enrollment successful! Backend handled first payment.
                                  }
                                }
                              }
                            : null,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: (isSelected && provider.isLoading)
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : Text(
                                !isSelected
                                    ? 'SELECT A GROUP'
                                    : (isCompleted
                                          ? 'GROUP COMPLETED'
                                          : 'CONTINUE TO PAYMENT'),
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: 1.0,
                                ),
                              ),
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEnhancedGroupInfo(EqubGroupModel group) {
    final primaryColor = Theme.of(context).primaryColor;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 20,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Enrollment Details',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: primaryColor,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color:
                      (group.status?.toLowerCase() == 'completed'
                              ? Colors.grey
                              : primaryColor)
                          .withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  group.status?.toUpperCase() ?? 'ACTIVE',
                  style: TextStyle(
                    color: group.status?.toLowerCase() == 'completed'
                        ? Colors.grey
                        : primaryColor,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _infoTile(
                Icons.payments_rounded,
                'Amount',
                CurrencyFormatter.format(
                  widget.package.contributionAmount ?? 0,
                ),
              ),
              _infoTile(
                Icons.event_repeat_rounded,
                'Schedule',
                widget.package.schedule?.name.toUpperCase() ?? 'N/A',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _infoTile(
                Icons.people_alt_rounded,
                'Group Size',
                '${widget.package.groupSize ?? 0} members',
              ),
              _infoTile(
                Icons.loop_rounded,
                'Cycle',
                'Round ${group.currentCycle ?? 0}',
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _infoTile(
                Icons.security_rounded,
                'Risk Reserve',
                CurrencyFormatter.format(group.riskReserve ?? 0),
              ),
              _infoTile(
                Icons.calendar_month_rounded,
                'Start Date',
                group.startDate != null
                    ? DateFormatter.format(group.startDate!, 'en')
                    : 'N/A',
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                group.status?.toUpperCase() ?? 'ACTIVE',
                style: const TextStyle(
                  fontSize: 11,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Text(
                'Live Status',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _infoTile(IconData icon, String label, String value) {
    return Expanded(
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.grey[50],
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon, size: 20, color: Colors.grey[600]),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
              ),
              Text(
                value,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
