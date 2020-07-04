import 'package:get/get.dart';
import 'package:get_only_example/core/services/api.dart';
import 'package:get_only_example/core/services/authentication_service.dart';
import 'package:get_only_example/core/viewmodels/login_model.dart';

class LoginBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<LoginModel>(() => LoginModel());
    Get.lazyPut<AuthenticationService>(() => AuthenticationService());
    Get.lazyPut<Api>(() => Api());
  }
}
