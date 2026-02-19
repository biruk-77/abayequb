import 'dart:ui';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:go_router/go_router.dart' as nav;
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

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen>
    with TickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _otpController = TextEditingController();

  bool _isOtpSent = false;
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
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _otpController.dispose();
    super.dispose();
  }

  Future<void> _handleRequestOtp() async {
    if (!_formKey.currentState!.validate()) return;

    final authProvider = context.read<AuthProvider>();
    try {
      await authProvider.requestOtp(
        '+${_selectedCountry.phoneCode}${_phoneController.text}',
        isRegister: true,
      );

      setState(() {
        _isOtpSent = true;
      });

      if (mounted) {
        if (authProvider.error == null) {
          _showSnackBar('Verification code sent to your phone', isError: false);
        } else {
          _showSnackBar(authProvider.error!);
        }
      }
    } catch (e) {
      if (mounted) {
        final error = authProvider.error ?? e.toString();
        _showSnackBar(error);

        if (error.contains('active') && error.contains('Expires in')) {
          final RegExp regExp = RegExp(r'(\d+)\s+seconds');
          final match = regExp.firstMatch(error);
          if (match != null) {
            _startCountdown(int.parse(match.group(1)!));
            setState(() => _isOtpSent = true);
          }
        }
      }
    }
  }

  Future<void> _handleVerifyAndRegister() async {
    // Validate all fields again
    if (!_formKey.currentState!.validate()) {
      _showSnackBar('Please correct the errors in the form');
      return;
    }

    if (_otpController.text.isEmpty) {
      _showSnackBar('Please enter the verification code');
      return;
    }

    try {
      await context.read<AuthProvider>().verifyOtp(
        phone: '+${_selectedCountry.phoneCode}${_phoneController.text}',
        otp: _otpController.text,
        isRegister: true,
        fullName: _nameController.text,
        email: _emailController.text,
        password: _passwordController.text,
      );

      if (mounted) {
        nav.GoRouter.of(context).go('/');
      }
    } catch (e) {
      if (mounted) {
        String error = context.read<AuthProvider>().error ?? e.toString();
        if (error.contains('DioException') && error.contains('400')) {
          error = 'Invalid details or OTP expired. Please try again.';
        }
        _showSnackBar(error);
      }
    }
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
    final isLoading = context.watch<AuthProvider>().isLoading;
    AppLogger.debug(
      'Building RegisterScreen - Screen Width: ${SizeConfig.screenWidth}',
    );

    return PopScope(
      canPop: !_isOtpSent,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        if (_isOtpSent) {
          setState(() => _isOtpSent = false);
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
                            _buildHeader(),
                            Transform.translate(
                              offset: const Offset(0, -40),
                              child: _buildGlassmorphicForm(isLoading),
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
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded),
                onPressed: () {
                  if (_isOtpSent) {
                    setState(() => _isOtpSent = false);
                  } else {
                    nav.GoRouter.of(context).pop();
                  }
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
    if (isSelected == false &&
        context.watch<LocaleProvider>().locale == null &&
        locale.languageCode == 'en') {
      isSelected = true;
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

  Widget _buildHeader() {
    final l10n = AbayLocalizations.of(context)!;
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
                        l10n.register,
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

  Widget _buildGlassmorphicForm(bool isLoading) {
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
                  if (!_isOtpSent) ...[
                    GlowingTextField(
                      controller: _nameController,
                      hintText: AbayLocalizations.of(context)!.fullName,
                      icon: Icons.person_outline,
                      validator: (v) => v == null || v.isEmpty
                          ? 'Please enter your name'
                          : null,
                    ),
                    const SizedBox(height: 16),
                    _buildPhoneInput(),
                    const SizedBox(height: 16),
                    GlowingTextField(
                      controller: _emailController,
                      hintText: AbayLocalizations.of(context)!.email,
                      icon: Icons.email_outlined,
                      keyboardType: TextInputType.emailAddress,
                      validator: (v) {
                        if (v == null || v.isEmpty)
                          return 'Please enter your email';
                        if (!v.contains('@') || !v.contains('.'))
                          return 'Please enter a valid email';
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),
                    _buildPasswordInput(),
                    const SizedBox(height: 24),
                    _buildSubmitButton(
                      AbayLocalizations.of(context)!.sendOtp,
                      _handleRequestOtp,
                      isLoading,
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
                      'Verify & Register',
                      _handleVerifyAndRegister,
                      isLoading,
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        TextButton(
                          onPressed: () => setState(() => _isOtpSent = false),
                          child: const Text('Edit Details'),
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
                      Text(AbayLocalizations.of(context)!.alreadyHaveAccount),
                      TextButton(
                        onPressed: () => nav.GoRouter.of(context).go('/login'),
                        child: Text(AbayLocalizations.of(context)!.login),
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

  Widget _buildPhoneInput() {
    final screenWidth = MediaQuery.of(context).size.width;
    return GlowingTextField(
      controller: _phoneController,
      hintText: 'Phone Number',
      keyboardType: TextInputType.phone,
      validator: (v) {
        if (v == null || v.isEmpty) return 'Please enter phone number';
        if (v.length < 9) return 'Invalid phone number';
        return null;
      },
      prefixWidget: GestureDetector(
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
    );
  }

  Widget _buildPasswordInput() {
    return GlowingTextField(
      controller: _passwordController,
      hintText: 'Password',
      icon: Icons.lock_outline,
      isObscured: _isPasswordObscured,
      validator: (v) => v == null || v.length < 6
          ? 'Password must be at least 6 characters'
          : null,
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
