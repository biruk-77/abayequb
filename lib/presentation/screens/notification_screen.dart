import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';
import '../../core/theme/app_theme.dart';
import '../../l10n/app_localizations.dart';
import '../providers/notification_provider.dart';
import '../../core/utils/date_formatter.dart';
import '../providers/locale_provider.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().fetchNotifications();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AbayLocalizations.of(context);
    final notificationProv = context.watch<NotificationProvider>();
    final notifications = notificationProv.notifications;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF050B14) : AppTheme.bgLight,
      body: Stack(
        children: [
          // Background accents
          Positioned(
            top: -100,
            right: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppTheme.primaryColor.withValues(alpha: 0.05),
              ),
            ),
          ),

          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildAppBar(context, l10n, isDark, notificationProv),

              if (notificationProv.isLoading)
                const SliverFillRemaining(
                  child: Center(child: CircularProgressIndicator()),
                )
              else if (notifications.isEmpty)
                SliverFillRemaining(child: _buildEmptyState(l10n, isDark))
              else
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(16, 20, 16, 100),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final notification = notifications[index];
                      return FadeInUp(
                        delay: Duration(milliseconds: index * 50),
                        child: _NotificationCard(
                          notification: notification,
                          onTap: () =>
                              notificationProv.markAsRead(notification.id),
                          isDark: isDark,
                        ),
                      );
                    }, childCount: notifications.length),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAppBar(
    BuildContext context,
    AbayLocalizations? l10n,
    bool isDark,
    NotificationProvider prov,
  ) {
    return SliverAppBar(
      pinned: true,
      expandedHeight: 120,
      backgroundColor: isDark ? const Color(0xFF050B14) : AppTheme.bgLight,
      elevation: 0,
      leading: IconButton(
        icon: Icon(
          Icons.arrow_back_ios_new_rounded,
          color: isDark ? Colors.white : AppTheme.primaryColor,
        ),
        onPressed: () => Navigator.pop(context),
      ),
      actions: [
        if (prov.notifications.isNotEmpty)
          TextButton(
            onPressed: () => prov.clearAll(),
            child: Text(
              l10n?.clearAll ?? 'Clear all',
              style: GoogleFonts.outfit(
                color: AppTheme.notificationRed,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        const SizedBox(width: 8),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.only(left: 56, bottom: 16),
        title: Text(
          l10n?.notifications ?? 'Notifications',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppTheme.primaryColor,
            fontSize: 24,
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(AbayLocalizations? l10n, bool isDark) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        FadeInDown(
          child: Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.05)
                  : AppTheme.primaryColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.notifications_none_rounded,
              size: 80,
              color: isDark
                  ? Colors.white24
                  : AppTheme.primaryColor.withValues(alpha: 0.2),
            ),
          ),
        ),
        const SizedBox(height: 24),
        FadeInUp(
          child: Text(
            l10n?.noNotifications ?? 'No notifications yet',
            style: GoogleFonts.outfit(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: isDark ? Colors.white70 : AppTheme.primaryColor,
            ),
          ),
        ),
        const SizedBox(height: 8),
        FadeInUp(
          delay: const Duration(milliseconds: 200),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: Text(
              l10n?.notificationsDescription ??
                  'Stay updated on your contributions, payouts, and group activities.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 14,
                color: isDark ? Colors.white38 : AppTheme.textSecondaryLight,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _NotificationCard extends StatelessWidget {
  final dynamic notification;
  final VoidCallback onTap;
  final bool isDark;

  const _NotificationCard({
    required this.notification,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    final locale = context.watch<LocaleProvider>().locale?.languageCode ?? 'en';
    final timeStr = DateFormatter.format(notification.createdAt, locale);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isDark
              ? (notification.isRead
                    ? const Color(0xFF0F172A)
                    : const Color(0xFF1E293B))
              : (notification.isRead
                    ? Colors.white
                    : AppTheme.primaryColor.withValues(alpha: 0.03)),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isDark
                ? (notification.isRead
                      ? Colors.white.withValues(alpha: 0.05)
                      : AppTheme.accentColor.withValues(alpha: 0.3))
                : (notification.isRead
                      ? Colors.grey.shade200
                      : AppTheme.primaryColor.withValues(alpha: 0.1)),
          ),
          boxShadow: [
            if (!notification.isRead)
              BoxShadow(
                color: isDark
                    ? AppTheme.accentColor.withValues(alpha: 0.05)
                    : AppTheme.primaryColor.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
          ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildTypeIcon(notification.type, notification.isRead),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: GoogleFonts.outfit(
                            fontWeight: notification.isRead
                                ? FontWeight.w600
                                : FontWeight.bold,
                            fontSize: 16,
                            color: isDark
                                ? Colors.white
                                : AppTheme.primaryColor,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: AppTheme.accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: GoogleFonts.outfit(
                      fontSize: 14,
                      color: isDark
                          ? Colors.white70
                          : AppTheme.textSecondaryLight,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    timeStr,
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isDark ? Colors.white38 : Colors.grey.shade500,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTypeIcon(String? type, bool isRead) {
    IconData icon;
    Color color;

    switch (type) {
      case 'contribution':
        icon = Icons.account_balance_wallet_rounded;
        color = Colors.blue;
        break;
      case 'payout':
        icon = Icons.emoji_events_rounded;
        color = Colors.amber;
        break;
      case 'group':
        icon = Icons.group_rounded;
        color = Colors.teal;
        break;
      default:
        icon = Icons.info_rounded;
        color = AppTheme.primaryColor;
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withOpacity(isRead ? 0.05 : 0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(icon, size: 20, color: color.withOpacity(isRead ? 0.5 : 1.0)),
    );
  }
}
