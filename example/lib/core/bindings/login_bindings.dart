import 'package:get/get.dart';

import '../services/api.dart';
import '../services/authentication_service.dart';
import '../viewmodels/login_model.dart';

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginModel>(() => LoginModel());
    Get.lazyPut<AuthenticationService>(() => AuthenticationService());
    Get.lazyPut<Api>(() => Api());
  }
}
