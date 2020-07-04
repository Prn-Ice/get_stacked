import 'package:get/get.dart';
import 'package:get_only_example/core/viewmodels/comments_model.dart';
import 'package:get_only_example/core/viewmodels/like_button_model.dart';
import 'package:get_only_example/core/viewmodels/post_model.dart';

class PostBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostModel>(() => PostModel());
    Get.lazyPut<CommentsModel>(() => CommentsModel());
    Get.lazyPut<LikeButtonModel>(() => LikeButtonModel());
  }
}