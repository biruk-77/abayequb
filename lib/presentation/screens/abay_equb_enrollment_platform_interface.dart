import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'abay_equb_enrollment_method_channel.dart';

abstract class AbayEqubEnrollmentPlatform extends PlatformInterface {
  /// Constructs a AbayEqubEnrollmentPlatform.
  AbayEqubEnrollmentPlatform() : super(token: _token);

  static final Object _token = Object();

  static AbayEqubEnrollmentPlatform _instance = MethodChannelAbayEqubEnrollment();

  /// The default instance of [AbayEqubEnrollmentPlatform] to use.
  ///
  /// Defaults to [MethodChannelAbayEqubEnrollment].
  static AbayEqubEnrollmentPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [AbayEqubEnrollmentPlatform] when
  /// they register themselves.
  static set instance(AbayEqubEnrollmentPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
