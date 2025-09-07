import 'package:get/get.dart';
import 'provider/video_provider.dart';
import 'provider/background_verification_provider.dart';

class AppBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut(() => VideoProvider(), fenix: true);
    Get.lazyPut(() => BackgroundVerificationProvider(), fenix: true);
  }
}
