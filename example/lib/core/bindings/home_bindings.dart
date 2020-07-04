import 'package:get/get.dart';
import 'package:get_only_example/core/services/posts_service.dart';
import 'package:get_only_example/core/viewmodels/home_model.dart';

class HomeBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostsService>(() => PostsService());
    Get.lazyPut<HomeModel>(() => HomeModel());
  }
}
