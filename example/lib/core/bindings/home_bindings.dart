import 'package:get/get.dart';

import '../services/posts_service.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostsService>(() => PostsService());
  }
}
