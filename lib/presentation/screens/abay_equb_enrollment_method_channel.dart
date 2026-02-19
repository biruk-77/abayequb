import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'abay_equb_enrollment_platform_interface.dart';

/// An implementation of [AbayEqubEnrollmentPlatform] that uses method channels.
class MethodChannelAbayEqubEnrollment extends AbayEqubEnrollmentPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('abay_equb_enrollment');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
