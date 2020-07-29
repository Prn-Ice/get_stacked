import 'package:get/get.dart';

import '../services/api.dart';
import '../services/authentication_service.dart';

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AuthenticationService>(() => AuthenticationService());
    Get.lazyPut<Api>(() => Api());
  }
}
