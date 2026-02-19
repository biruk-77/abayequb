
import 'abay_equb_enrollment_platform_interface.dart';

class AbayEqubEnrollment {
  Future<String?> getPlatformVersion() {
    return AbayEqubEnrollmentPlatform.instance.getPlatformVersion();
  }
}
