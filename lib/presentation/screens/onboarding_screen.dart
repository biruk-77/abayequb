import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:introduction_screen/introduction_screen.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/app_theme.dart';
import '../providers/auth_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final _introKey = GlobalKey<IntroductionScreenState>();

  Future<void> _onIntroEnd(BuildContext context) async {
    // Update provider state (which also updates SharedPreferences)
    await context.read<AuthProvider>().completeOnboarding();

    if (context.mounted) {
      context.go('/login');
    }
  }

  Widget _buildImage(String assetName, [double width = 350]) {
    // Fallback to network if asset not found for this demo
    // In production, ensure assets exist
    return Image.asset(
      'assets/images/$assetName',
      width: width,
      errorBuilder: (context, error, stackTrace) {
        // Fallback icon or empty
        return const Icon(
          Icons.image_not_supported,
          size: 100,
          color: Colors.grey,
        );
      },
    );
  }

  // Helper for network images in this prototype
  Widget _buildNetworkImage(String url) {
    return Center(
      child: Container(
        constraints: const BoxConstraints(maxHeight: 250),
        child: Image.network(url, fit: BoxFit.contain),
      ),
    );
  }

  // Helper to build page view model with consistent styling
  PageViewModel _buildPage({
    required String title,
    required String body,
    required String? imageAsset,
    String? imageUrl,
  }) {
    return PageViewModel(
      title: title,
      body: body,
      image: imageUrl != null
          ? _buildNetworkImage(imageUrl)
          : (imageAsset != null ? _buildImage(imageAsset) : const SizedBox()),
      decoration: PageDecoration(
        titleTextStyle: GoogleFonts.outfit(
          fontSize: 28.0,
          fontWeight: FontWeight.w700,
          color: AppTheme.primaryColor,
        ),
        bodyTextStyle: GoogleFonts.outfit(
          fontSize: 19.0,
          color: Colors.black54,
        ),
        bodyPadding: const EdgeInsets.fromLTRB(16.0, 0.0, 16.0, 16.0),
        // pageColor: decorationColor ?? Colors.white, // Conflict with boxDecoration
        imagePadding: const EdgeInsets.all(24.0),
        imageFlex: 2, // Allocate more space for image
        boxDecoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.white, AppTheme.bgLight],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pages = [
      // Slide 1: Welcome / What is Equb
      _buildPage(
        title: "Welcome to Abay eQub",
        body:
            "A modern, digital version of the traditional Ethiopian saving circle. Join trusted groups to save together and grow together.",
        imageUrl:
            'https://cdn-icons-png.flaticon.com/512/2830/2830305.png', // Placeholder
        imageAsset: null,
      ),
      // Slide 2: Contribution Flow
      _buildPage(
        title: "Easy Contributions",
        body:
            "Select a package that fits your budget. contribute daily, weekly, or monthly using secure mobile payments or bank transfers.",
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2830/2830289.png',
        imageAsset: null,
      ),
      // Slide 3: Payout Flow
      _buildPage(
        title: "Fair & Transparent Payouts",
        body:
            "Wins are determined by fair lots or rotation. Get notified instantly when it's your turn to receive the pot!",
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2830/2830311.png',
        imageAsset: null,
      ),
      // Slide 4: Trust & Penalties
      _buildPage(
        title: "Built on Trust",
        body:
            "We value commitment. Late payments may incur small penalties to ensure fairness for everyone. Build your Trust Score to access premium groups.",
        imageUrl: 'https://cdn-icons-png.flaticon.com/512/2830/2830325.png',
        imageAsset: null,
      ),
    ];

    return IntroductionScreen(
      key: _introKey,
      globalBackgroundColor: Colors.white,
      allowImplicitScrolling: true,
      autoScrollDuration: 5000,
      pages: pages,
      onDone: () => _onIntroEnd(context),
      onSkip: () => _onIntroEnd(context), // You can override onSkip callback
      showSkipButton: true,
      skipOrBackFlex: 0,
      nextFlex: 0,
      showBackButton: false,
      //rtl: true, // Display as right-to-left
      back: const Icon(Icons.arrow_back),
      skip: const Text(
        'Skip',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
      next: const Icon(Icons.arrow_forward, color: AppTheme.primaryColor),
      done: const Text(
        'Continue',
        style: TextStyle(
          fontWeight: FontWeight.w600,
          color: AppTheme.primaryColor,
        ),
      ),
      curve: Curves.fastLinearToSlowEaseIn,
      controlsMargin: const EdgeInsets.all(16),
      controlsPadding: const EdgeInsets.fromLTRB(8.0, 4.0, 8.0, 4.0),
      dotsDecorator: const DotsDecorator(
        size: Size(10.0, 10.0),
        color: Color(0xFFBDBDBD),
        activeSize: Size(22.0, 10.0),
        activeShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(25.0)),
        ),
        activeColor: AppTheme.primaryColor,
      ),
    );
  }
}
