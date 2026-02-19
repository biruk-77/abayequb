// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AbayLocalizationsEn extends AbayLocalizations {
  AbayLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appName => 'Abay eQub';

  @override
  String get welcome => 'Welcome';

  @override
  String get totalBalance => 'Total Balance';

  @override
  String get contribute => 'CONTRIBUTE';

  @override
  String get selectPackage => 'Select Package';

  @override
  String get chooseGroup => 'Choose Group Type';

  @override
  String get joinGroup => 'Join Group';

  @override
  String get payment => 'Payment';

  @override
  String get confirmPayment => 'Confirm Payment';

  @override
  String get success => 'Success';

  @override
  String get error => 'Error';

  @override
  String get locked => 'Locked';

  @override
  String get login => 'Login';

  @override
  String get register => 'Register';

  @override
  String get phone => 'Phone Number';

  @override
  String get password => 'Password';

  @override
  String get fullName => 'Full Name';

  @override
  String get email => 'Email Address';

  @override
  String get sendOtp => 'Send OTP';

  @override
  String get verifyLogin => 'Verify & Login';

  @override
  String get otpSent => 'OTP Sent';

  @override
  String get dontHaveAccount => 'Don\'t have an account?';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get welcomeBack => 'Welcome Back';

  @override
  String get joinAbayEqub => 'Join Abay eQub';

  @override
  String get flowingWealth => 'Flowing Wealth, Shared Future';

  @override
  String get home => 'Home';

  @override
  String get history => 'History';

  @override
  String get profile => 'Profile';

  @override
  String get aboutAbay => 'About Abay eQub';

  @override
  String get settings => 'Settings';

  @override
  String get logout => 'Logout';

  @override
  String get confirmLogout => 'Are you sure you want to logout?';

  @override
  String get cancel => 'Cancel';

  @override
  String get availableBalance => 'Available Balance';

  @override
  String lockedBalance(String amount) {
    return 'Locked: $amount ETB';
  }

  @override
  String get seeAll => 'See All';

  @override
  String get language => 'Language';

  @override
  String get theme => 'Theme';

  @override
  String get light => 'Light';

  @override
  String get dark => 'Dark';

  @override
  String get system => 'System';

  @override
  String get yourActiveEqubs => 'Your Active eQubs';

  @override
  String get explorePackages => 'Explore Packages';

  @override
  String get nextContribution => 'Next Contribution';

  @override
  String get nextPayout => 'Next Payout';

  @override
  String get join => 'Join';

  @override
  String get joining => 'Joining...';

  @override
  String get joinedSuccess => 'Successfully joined group';

  @override
  String get joinFailed => 'Failed to join group';

  @override
  String get walletRequired => 'Wallet setup required';

  @override
  String get alreadyMember => 'Already a member of this group';

  @override
  String get joinGroupConfirmation => 'Are you sure you want to join';
}
