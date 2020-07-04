import 'package:get/get.dart';

import '../services/posts_service.dart';
import '../viewmodels/home_model.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostsService>(() => PostsService());
    Get.lazyPut<HomeModel>(() => HomeModel());
  }
}
