import 'package:get/get.dart';

import '../viewmodels/comments_model.dart';
import '../viewmodels/like_button_model.dart';
import '../viewmodels/post_model.dart';

class PostBindings extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PostModel>(() => PostModel());
    Get.lazyPut<CommentsModel>(() => CommentsModel());
    Get.lazyPut<LikeButtonModel>(() => LikeButtonModel());
  }
}
