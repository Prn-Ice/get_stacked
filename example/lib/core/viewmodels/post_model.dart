import 'package:get/get.dart';
import 'package:get_stacked/get_stacked.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../services/authentication_service.dart';

class PostModel extends BaseGetController {
  Post get post => Get.arguments;
  User get user => Get.find<AuthenticationService>().userController.value;
}
