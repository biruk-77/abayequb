// ignore_for_file: deprecated_member_use
// lib/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../providers/auth_provider.dart';
import '../providers/equb_provider.dart';
import '../providers/wallet_provider.dart';
import '../providers/notification_provider.dart';
import '../../data/models/kyc_model.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../../l10n/app_localizations.dart';
import '../../core/theme/app_theme.dart';
import '../widgets/abay_icon.dart';
import '../../data/services/notification_service.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _notificationsEnabled = true;

  // ── SharedPreferences keys ─────────────────────────────────────
  static const _kNotif = 'notif_enabled';

  @override
  void initState() {
    super.initState();
    _loadNotifPrefs();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final authProvider = p.Provider.of<AuthProvider>(context, listen: false);
      authProvider.refreshUser();
      authProvider.fetchKYCStatus();
    });
  }

  Future<void> _loadNotifPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    if (!mounted) return;
    setState(() {
      _notificationsEnabled = prefs.getBool(_kNotif) ?? true;
    });
  }

  Future<void> _saveNotifPref(String key, bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(key, value);
  }

  @override
  Widget build(BuildContext context) {
    final user = p.Provider.of<AuthProvider>(context).user;
    final localeProvider = p.Provider.of<LocaleProvider>(context);
    final themeProvider = p.Provider.of<ThemeProvider>(context);
    final l10n = AbayLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.profile), elevation: 0),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // User Info Header
            _buildUserInfoHeader(context, user),

            const SizedBox(height: 16),

            // Personal Info Section
            _buildSection(
              context,
              title: 'Personal Information',
              icon: Icons.person_outline,
              children: [
                _buildInfoTile(
                  context,
                  label: 'Full Name',
                  value: user?.fullName ?? 'Not set',
                  icon: Icons.person,
                  onTap: () => context.push('/profile/edit'),
                ),
                _buildInfoTile(
                  context,
                  label: 'Email',
                  value: user?.email ?? 'Not set',
                  icon: Icons.email,
                  onTap: () => context.push('/profile/edit'),
                ),
                _buildInfoTile(
                  context,
                  label: 'Phone',
                  value: user?.phoneNumber ?? 'Not set',
                  icon: Icons.phone,
                  onTap: () => context.push('/profile/edit'),
                ),
              ],
            ),

            // KYC Section
            _buildSection(
              context,
              title: 'KYC Verification',
              icon: Icons.verified_user_outlined,
              children: [
                _buildKYCStatus(context),
                const SizedBox(height: 8),
                p.Consumer<AuthProvider>(
                  builder: (context, auth, _) {
                    final kyc = auth.kyc;
                    final status = kyc?.status;

                    String label = 'Upload Documents';
                    bool isDisabled = false;
                    IconData icon = Icons.upload_file;
                    Color? bgColor;

                    if (status == KYCStatus.verified) {
                      label = 'Verified';
                      isDisabled = true;
                      icon = Icons.check_circle;
                      bgColor = Colors.green;
                    } else if (status == KYCStatus.pending) {
                      label = 'Under Review';
                      isDisabled = true;
                      icon = Icons.hourglass_empty;
                      bgColor = Colors.orange;
                    } else if (status == KYCStatus.rejected) {
                      label = 'Update Documents';
                      icon = Icons.update;
                    }

                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 16),
                      child: ElevatedButton.icon(
                        onPressed: isDisabled
                            ? null
                            : () => context.push('/profile/kyc'),
                        icon: Icon(icon),
                        label: Text(
                          label,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 48),
                          backgroundColor: bgColor,
                          foregroundColor: bgColor != null
                              ? Colors.white
                              : null,
                          disabledBackgroundColor: bgColor?.withValues(
                            alpha: 0.6,
                          ),
                          disabledForegroundColor: Colors.white,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),

            // Language Selection
            _buildSection(
              context,
              title: 'Language',
              icon: Icons.language,
              children: [_buildLanguageSelector(context, localeProvider)],
            ),

            // Appearance
            _buildSection(
              context,
              title: 'Appearance',
              icon: Icons.palette_outlined,
              children: [
                _buildThemeSelector(context, themeProvider),
                const Divider(height: 1, indent: 56),
                _buildSwitchTile(
                  context,
                  title: 'Simple Mode',
                  subtitle: 'Larger text and simplified interface',
                  value: themeProvider.isSimpleMode,
                  onChanged: (value) {
                    themeProvider.toggleSimpleMode(value);
                  },
                ),
              ],
            ),

            // Notifications
            _buildSection(
              context,
              title: 'Notifications',
              icon: Icons.notifications_outlined,
              children: [
                _buildSwitchTile(
                  context,
                  title: 'App Notifications',
                  subtitle: 'Receive eQub alerts and updates',
                  value: _notificationsEnabled,
                  onChanged: (value) async {
                    setState(() => _notificationsEnabled = value);
                    await _saveNotifPref(_kNotif, value);

                    if (value) {
                      await FirebaseNotificationService().enableNotifications();
                    } else {
                      await FirebaseNotificationService()
                          .disableNotifications();
                    }
                  },
                ),
              ],
            ),

            // Account Actions
            _buildSection(
              context,
              title: 'Account',
              icon: Icons.settings,
              children: [
                _buildInfoTile(
                  context,
                  label: 'Security',
                  value: 'Edit All Details',
                  icon: Icons.edit_note_rounded,
                  onTap: () => context.push('/profile/edit'),
                ),
                const Divider(height: 1, indent: 56),
                ListTile(
                  leading: const Icon(Icons.logout, color: Colors.red),
                  title: const Text(
                    'Logout',
                    style: TextStyle(
                      color: Colors.red,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                    color: Colors.red,
                  ),
                  onTap: () => _confirmLogout(context),
                ),
              ],
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }

  Widget _buildUserInfoHeader(BuildContext context, user) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: AppTheme.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(32),
          bottomRight: Radius.circular(32),
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          GestureDetector(
            onTap: () => context.push('/profile/edit'),
            child: Stack(
              children: [
                CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.white,
                  backgroundImage:
                      user?.profileImage != null &&
                          user!.profileImage!.isNotEmpty
                      ? AbayIcon.getImageProvider(user.profileImage!)
                      : null,
                  child:
                      user?.profileImage == null || user!.profileImage!.isEmpty
                      ? Text(
                          user?.fullName?.substring(0, 1).toUpperCase() ?? 'U',
                          style: GoogleFonts.outfit(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: AppTheme.primaryColor,
                          ),
                        )
                      : null,
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    padding: const EdgeInsets.all(4),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.camera_alt,
                      size: 20,
                      color: AppTheme.primaryColor,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            user?.fullName ?? 'User',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            user?.email ?? user?.phoneNumber ?? '',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 12),
          if (user?.trustScore != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(Icons.verified_user_rounded,
                      color: Colors.white, size: 14),
                  const SizedBox(width: 6),
                  Text(
                    'TRUST SCORE: ${user!.trustScore}',
                    style: GoogleFonts.outfit(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 0.5,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildSection(
    BuildContext context, {
    required String title,
    required IconData icon,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              Icon(icon, size: 20, color: AppTheme.primaryColor),
              const SizedBox(width: 8),
              Text(
                title,
                style: GoogleFonts.outfit(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                ),
              ),
            ],
          ),
        ),
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.1),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(children: children),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required String label,
    required String value,
    required IconData icon,
    VoidCallback? onTap,
  }) {
    final theme = Theme.of(context);
    return ListTile(
      leading: Icon(icon, color: AppTheme.primaryColor),
      title: Text(
        label,
        style: TextStyle(fontSize: 12, color: theme.hintColor),
      ),
      subtitle: Text(
        value,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: theme.textTheme.bodyLarge?.color,
        ),
      ),
      trailing: Icon(Icons.edit, size: 20, color: theme.hintColor),
      onTap: onTap,
    );
  }

  Widget _buildKYCStatus(BuildContext context) {
    final kyc = p.Provider.of<AuthProvider>(context).kyc;
    final kycStatus = kyc?.status;
    Color statusColor;
    IconData statusIcon;
    String statusText;

    if (kycStatus == KYCStatus.verified) {
      statusColor = Colors.green;
      statusIcon = Icons.check_circle;
      statusText = 'Verified';
    } else if (kycStatus == KYCStatus.pending) {
      statusColor = Colors.orange;
      statusIcon = Icons.pending;
      statusText = 'Pending Review';
    } else if (kycStatus == KYCStatus.rejected) {
      statusColor = Colors.red;
      statusIcon = Icons.cancel;
      statusText = 'Rejected';
    } else {
      statusColor = Colors.grey;
      statusIcon = Icons.help_outline;
      statusText = 'Not Uploaded';
    }

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: statusColor),
      ),
      child: Row(
        children: [
          Icon(statusIcon, color: statusColor, size: 32),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'KYC Status',
                  style: TextStyle(fontSize: 12, color: Colors.grey[600]),
                ),
                Text(
                  statusText,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: statusColor,
                  ),
                ),
                if (kyc != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      'Document: ${kyc.documentType}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeSelector(
    BuildContext context,
    ThemeProvider themeProvider,
  ) {
    return Column(
      children: [
        RadioListTile<ThemeMode>(
          title: const Text('Light'),
          secondary: const Icon(Icons.light_mode_outlined),
          value: ThemeMode.light,
          groupValue: themeProvider.themeMode,
          onChanged: (value) => themeProvider.setThemeMode(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('Dark'),
          secondary: const Icon(Icons.dark_mode_outlined),
          value: ThemeMode.dark,
          groupValue: themeProvider.themeMode,
          onChanged: (value) => themeProvider.setThemeMode(value!),
        ),
        RadioListTile<ThemeMode>(
          title: const Text('System'),
          secondary: const Icon(Icons.settings_suggest_outlined),
          value: ThemeMode.system,
          groupValue: themeProvider.themeMode,
          onChanged: (value) => themeProvider.setThemeMode(value!),
        ),
      ],
    );
  }

  Widget _buildLanguageSelector(
    BuildContext context,
    LocaleProvider localeProvider,
  ) {
    final currentLocale = localeProvider.locale?.languageCode ?? 'en';
    return Column(
      children: [
        RadioListTile<String>(
          title: const Text('English'),
          subtitle: const Text('English'),
          value: 'en',
          groupValue: currentLocale,
          onChanged: (value) => localeProvider.setLocale(const Locale('en')),
        ),
        RadioListTile<String>(
          title: const Text('አማርኛ'),
          subtitle: const Text('Amharic'),
          value: 'am',
          groupValue: currentLocale,
          onChanged: (value) => localeProvider.setLocale(const Locale('am')),
        ),
      ],
    );
  }

  Widget _buildSwitchTile(
    BuildContext context, {
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      onChanged: onChanged,
      activeThumbColor: AppTheme.primaryColor,
    );
  }

  void _confirmLogout(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Confirm Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () async {
              Navigator.pop(context);
              await p.Provider.of<EqubProvider>(
                context,
                listen: false,
              ).clearData();
              p.Provider.of<WalletProvider>(
                context,
                listen: false,
              ).clearData();
              await p.Provider.of<NotificationProvider>(
                context,
                listen: false,
              ).clearData();
              await p.Provider.of<AuthProvider>(
                context,
                listen: false,
              ).logout();
              if (context.mounted) context.go('/login');
            },
            child: const Text('Logout'),
          ),
        ],
      ),
    );
  }
}
