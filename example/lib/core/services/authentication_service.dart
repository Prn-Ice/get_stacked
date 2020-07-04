import 'dart:async';

import 'package:get/get.dart';
import 'package:get_only_example/core/models/user.dart';

import 'api.dart';

class AuthenticationService {
  Api _api = Get.find<Api>();

  final userController = User.initial().obs;

  Future<bool> login(int userId) async {
    var fetchedUser = await _api.getUserProfile(userId);

    var hasUser = fetchedUser != null;
    if (hasUser) {
      print(fetchedUser.name);
      userController.value = fetchedUser;
    }

    return hasUser;
  }
}
