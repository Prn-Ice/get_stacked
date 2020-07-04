import 'package:get/get.dart';
import 'package:get_only_example/core/services/posts_service.dart';
import 'package:get_only_example/core/viewmodels/like_button_model.dart';
import 'package:get_only_example/core/viewmodels/post_model.dart';

import 'core/services/api.dart';
import 'core/services/authentication_service.dart';
import 'core/viewmodels/comments_model.dart';
import 'core/viewmodels/home_model.dart';
import 'core/viewmodels/login_model.dart';


void setupLocator() {
  Get.lazyPut<AuthenticationService>(()=> AuthenticationService());
  Get.lazyPut<Api>(()=> Api());
  Get.lazyPut<PostsService>(()=> PostsService());

  Get.lazyPut<LoginModel>(()=> LoginModel());
  Get.lazyPut<HomeModel>(()=> HomeModel());
  Get.lazyPut<CommentsModel>(()=> CommentsModel());
  Get.lazyPut<PostModel>(()=> PostModel());
  Get.lazyPut<LikeButtonModel>(()=> LikeButtonModel());
}
