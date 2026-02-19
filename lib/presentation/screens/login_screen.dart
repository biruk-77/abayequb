import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart' as p;
import 'package:go_router/go_router.dart';
import 'package:animate_do/animate_do.dart';
import 'package:country_picker/country_picker.dart';
import '../../l10n/app_localizations.dart';
import '../providers/locale_provider.dart';
import '../providers/theme_provider.dart';
import '../../core/utils/size_config.dart';
import '../../core/utils/logger.dart';
import '../providers/auth_provider.dart';
import '../widgets/glowing_text_field.dart';
import '../widgets/branded_loading_indicator.dart';
import '../../core/theme/app_theme.dart';

import 'dart:async';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _isOtpSent = false;
  final bool _isRegistering = false;
  bool _showPasswordField = false;
  bool _isPasswordObscured = true;
  int _otpCountdown = 0;
  Timer? _countdownTimer;

  Country _selectedCountry = Country.parse('ET');
  late final AnimationController _glowController;

  @override
  void initState() {
    super.initState();
    _glowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat(reverse: true);
  }

  void _startCountdown(int seconds) {
    _countdownTimer?.cancel();
    setState(() => _otpCountdown = seconds);
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_otpCountdown > 0) {
        setState(() => _otpCountdown--);
      } else {
        timer.cancel();
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _glowController.dispose();
    _phoneController.dispose();
    _otpController.dispose();
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    if (_phoneController.text.isEmpty) return;

    final authProvider = p.Provider.of<AuthProvider>(context, listen: false);
    try {
      await authProvider.requestOtp(
        '+${_selectedCountry.phoneCode}${_phoneController.text}',
        isRegister: _isRegistering,
      );

      setState(() {
        _isOtpSent = true;
      });

      if (mounted) {
        if (authProvider.error == null) {
          _showSnackBar('OTP Sent', isError: false);
        } else {
          _showSnackBar(authProvider.error!);
        }
      }
    } catch (e) {
      if (mounted) {
        final error = authProvider.error ?? e.toString();
        _showSnackBar(error);

        // Extract seconds if OTP is already active
        if (error.contains('active') && error.contains('Expires in')) {
          final RegExp regExp = RegExp(r'(\d+)\s+seconds');
          final match = regExp.firstMatch(error);
          if (match != null) {
            _startCountdown(int.parse(match.group(1)!));
            setState(() => _isOtpSent = true); // Transition to OTP input
          }
        }
      }
    }
  }

  Future<void> _handleVerifyOtp() async {
    if (_otpController.text.isEmpty) return;

    try {
      await context.read<AuthProvider>().verifyOtp(
        phone: '+${_selectedCountry.phoneCode}${_phoneController.text}',
        otp: _otpController.text,
        isRegister: _isRegistering,
        fullName: _isRegistering ? _nameController.text : null,
        email: _isRegistering ? _emailController.text : null,
        password: _isRegistering ? _passwordController.text : null,
      );

      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString());
      }
    }
  }

  Future<void> _handlePasswordLogin() async {
    try {
      await context.read<AuthProvider>().login(
        _phoneController.text.contains('@')
            ? _phoneController.text
            : '+${_selectedCountry.phoneCode}${_phoneController.text}',
        _passwordController.text,
      );
      if (mounted) {
        context.go('/');
      }
    } catch (e) {
      if (mounted) {
        _showSnackBar(e.toString());
      }
    }
  }

  void _showForgotPasswordDialog() {
    final phoneController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Reset Password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Enter your phone number to receive a reset code.'),
            const SizedBox(height: 16),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(
                labelText: 'Phone Number',
                prefixText: '+251 ',
              ),
              keyboardType: TextInputType.phone,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              final phone = '+251${phoneController.text}';
              Navigator.pop(ctx);
              try {
                await p.Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).requestForgotPassword(phone);
                _showResetPasswordDialog(phone);
              } catch (e) {
                _showSnackBar(e.toString());
              }
            },
            child: const Text('Send Code'),
          ),
        ],
      ),
    );
  }

  void _showResetPasswordDialog(String phone) {
    final otpController = TextEditingController();
    final passController = TextEditingController();
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        title: const Text('Verify & Reset'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Enter code sent to $phone'),
            const SizedBox(height: 16),
            TextField(
              controller: otpController,
              decoration: const InputDecoration(labelText: 'Verification Code'),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passController,
              decoration: const InputDecoration(labelText: 'New Password'),
              obscureText: true,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              try {
                await p.Provider.of<AuthProvider>(
                  context,
                  listen: false,
                ).verifyForgotPassword(
                  phone: phone,
                  otp: otpController.text,
                  newPassword: passController.text,
                );
                Navigator.pop(ctx);
                _showSnackBar(
                  'Password reset successful! Please login.',
                  isError: false,
                );
              } catch (e) {
                _showSnackBar(e.toString());
              }
            },
            child: const Text('Reset Password'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message, {bool isError = true}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isError ? Icons.error_outline : Icons.check_circle_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).primaryColor,
      ),
    );
  }

  void _pickCountry() {
    showCountryPicker(
      context: context,
      favorite: ['ET'],
      onSelect: (Country country) => setState(() => _selectedCountry = country),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AbayLocalizations.of(context);
    if (l10n == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final isLoading = context.watch<AuthProvider>().isLoading;
    AppLogger.debug(
      'Building LoginScreen - Screen Width: ${SizeConfig.screenWidth}',
    );

    return PopScope(
      canPop: !_isOtpSent && !_showPasswordField,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isOtpSent) {
          setState(() => _isOtpSent = false);
        } else if (_showPasswordField) {
          setState(() => _showPasswordField = false);
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            _buildAnimatedBackground(),
            SafeArea(
              child: Column(
                children: [
                  _buildTopBar(),
                  Expanded(
                    child: Center(
                      child: SingleChildScrollView(
                        padding: EdgeInsets.symmetric(
                          horizontal: SizeConfig.scaleWidth(24),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            _buildHeader(l10n),
                            Transform.translate(
                              offset: const Offset(0, -40),
                              child: _buildGlassmorphicForm(l10n, isLoading),
                            ),
                          ],
                        ),
                      ),
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

  Widget _buildAnimatedBackground() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppTheme.bgDark : AppTheme.bgLight,
      ),
      child: Stack(
        children: [
          // Dynamic mesh-like glow
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) => Positioned(
              top: -100 + (50 * _glowController.value),
              left: -100 + (30 * _glowController.value),
              child: Container(
                width: 300,
                height: 300,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.primaryColor.withOpacity(isDark ? 0.15 : 0.1),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          AnimatedBuilder(
            animation: _glowController,
            builder: (context, child) => Positioned(
              bottom: 100 - (40 * _glowController.value),
              right: -50 + (20 * _glowController.value),
              child: Container(
                width: 400,
                height: 400,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: RadialGradient(
                    colors: [
                      AppTheme.accentColor.withOpacity(isDark ? 0.1 : 0.05),
                      Colors.transparent,
                    ],
                  ),
                ),
              ),
            ),
          ),
          // Subtle grid pattern for texture
          Opacity(
            opacity: isDark ? 0.05 : 0.02,
            child: GridView.builder(
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 10,
              ),
              itemBuilder: (context, index) => Container(
                decoration: BoxDecoration(
                  border: Border.all(color: AppTheme.primaryColor, width: 0.5),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopBar() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (_isOtpSent || _showPasswordField)
                IconButton(
                  icon: const Icon(Icons.arrow_back_ios_new_rounded),
                  onPressed: () {
                    setState(() {
                      _isOtpSent = false;
                      _showPasswordField = false;
                    });
                  },
                  color: Theme.of(context).primaryColor,
                  iconSize: 20,
                ),
              _buildLanguageButton('EN', const Locale('en')),
              const SizedBox(width: 8),
              _buildLanguageButton('አ', const Locale('am')),
            ],
          ),
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().themeMode == ThemeMode.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
              color: Theme.of(context).primaryColor,
            ),
            onPressed: () {
              final provider = context.read<ThemeProvider>();
              provider.setThemeMode(
                provider.themeMode == ThemeMode.dark
                    ? ThemeMode.light
                    : ThemeMode.dark,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageButton(String label, Locale locale) {
    bool isSelected =
        context.watch<LocaleProvider>().locale?.languageCode ==
        locale.languageCode;
    if (context.watch<LocaleProvider>().locale == null &&
        locale.languageCode == 'en') {
      isSelected = true; // Default to English
    }

    return GestureDetector(
      onTap: () => context.read<LocaleProvider>().setLocale(locale),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? Theme.of(context).primaryColor
              : Colors.transparent,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Theme.of(context).primaryColor),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Theme.of(context).primaryColor,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(AbayLocalizations l10n) {
    return Column(
      children: [
        Transform.translate(
          offset: const Offset(0, -60),
          child: Column(
            children: [
              FadeInDown(
                child: Image.asset(
                  'assets/images/logo2.png',
                  height: SizeConfig.scaleHeight(260),
                  width: SizeConfig.scaleHeight(260),
                  fit: BoxFit.contain,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -30),
                child: Column(
                  children: [
                    FadeInDown(
                      delay: const Duration(milliseconds: 100),
                      child: Text(
                        _isRegistering ? l10n.joinAbayEqub : l10n.welcomeBack,
                        style: TextStyle(
                          fontSize: SizeConfig.scaleText(32),
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildGlassmorphicForm(AbayLocalizations l10n, bool isLoading) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return FadeInUp(
      delay: const Duration(milliseconds: 300),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(32),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 16, sigmaY: 16),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: isDark
                  ? Colors.white.withOpacity(0.05)
                  : Colors.white.withOpacity(0.7),
              borderRadius: BorderRadius.circular(32),
              border: Border.all(
                color: isDark
                    ? Colors.white.withOpacity(0.1)
                    : Colors.white.withOpacity(0.4),
                width: 1.5,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
                  blurRadius: 30,
                  offset: const Offset(0, 15),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (!_isOtpSent && !_showPasswordField) ...[
                    _buildPhoneInput(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(
                      l10n.sendOtp,
                      _handleRequestOtp,
                      isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          setState(() => _showPasswordField = true),
                      child: Text("${l10n.login} with Password"),
                    ),
                    if (_showPasswordField)
                      TextButton(
                        onPressed: _showForgotPasswordDialog,
                        child: const Text('Forgot Password?'),
                      ),
                  ] else if (_showPasswordField) ...[
                    _buildPhoneInput(label: "${l10n.phone} or Email"),
                    const SizedBox(height: 16),
                    _buildPasswordInput(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(
                      l10n.login,
                      _handlePasswordLogin,
                      isLoading,
                    ),
                    const SizedBox(height: 16),
                    TextButton(
                      onPressed: () =>
                          setState(() => _showPasswordField = false),
                      child: const Text('Use OTP instead'),
                    ),
                  ] else ...[
                    GlowingTextField(
                      controller: _otpController,
                      hintText: 'Verification Code',
                      icon: Icons.security,
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 16),
                    if (_otpCountdown > 0)
                      Text(
                        'Resend code in ${_otpCountdown}s',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: SizeConfig.scaleText(14),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    const SizedBox(height: 24),
                    _buildSubmitButton(
                      l10n.verifyLogin,
                      _handleVerifyOtp,
                      isLoading,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _isOtpSent = false),
                          child: const Text('Edit Phone'),
                        ),
                        if (_otpCountdown == 0)
                          TextButton(
                            onPressed: _handleRequestOtp,
                            child: const Text('Resend OTP'),
                          ),
                      ],
                    ),
                  ],
                  const SizedBox(height: 24),
                  Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(l10n.dontHaveAccount),
                      TextButton(
                        onPressed: () => context.push('/register'),
                        child: Text(l10n.register),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPhoneInput({String label = 'Phone Number'}) {
    final screenWidth = MediaQuery.of(context).size.width;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GlowingTextField(
          controller: _phoneController,
          hintText: label,
          keyboardType: _showPasswordField
              ? TextInputType.emailAddress
              : TextInputType.phone,
          prefixWidget:
              _showPasswordField && _phoneController.text.contains('@')
              ? Padding(
                  padding: const EdgeInsets.only(left: 14, right: 10),
                  child: Icon(
                    Icons.person,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                )
              : GestureDetector(
                  onTap: _pickCountry,
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(left: 14, right: 8),
                        child: Text(
                          _selectedCountry.flagEmoji,
                          style: const TextStyle(fontSize: 20),
                        ),
                      ),
                      Text(
                        '+${_selectedCountry.phoneCode}',
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontWeight: FontWeight.bold,
                          fontSize: screenWidth < 360 ? 14 : 16,
                        ),
                      ),
                      Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                      ),
                      Container(
                        width: 1,
                        height: 20,
                        color: Colors.grey.withOpacity(0.3),
                        margin: const EdgeInsets.symmetric(horizontal: 10),
                      ),
                    ],
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildPasswordInput() {
    return GlowingTextField(
      controller: _passwordController,
      hintText: 'Password',
      icon: Icons.lock_outline,
      isObscured: _isPasswordObscured,
      suffixIcon: IconButton(
        icon: Icon(
          _isPasswordObscured ? Icons.visibility_off : Icons.visibility,
          color: Theme.of(context).textTheme.bodySmall?.color,
        ),
        onPressed: () =>
            setState(() => _isPasswordObscured = !_isPasswordObscured),
      ),
    );
  }

  Widget _buildSubmitButton(
    String label,
    VoidCallback onPressed,
    bool isLoading,
  ) {
    return Container(
      width: double.infinity,
      height: 56,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        gradient: AppTheme.primaryGradient,
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryColor.withOpacity(0.3),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: isLoading
            ? const BrandedLoadingIndicator(size: 24, color: Colors.white)
            : Text(
                label,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
      ),
    );
  }
}
