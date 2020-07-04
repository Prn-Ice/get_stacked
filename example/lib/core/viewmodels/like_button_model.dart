import 'package:get/get.dart';
import 'package:get_only_example/core/services/posts_service.dart';
import 'package:get_stacked/get_stacked.dart';

class LikeButtonModel extends BaseGetController {
  PostsService _postsService = Get.find<PostsService>();

  int postLikes(int postId) {
    return _postsService.posts
        .firstWhere((post) => post.id == postId)
        .likes
        .value;
  }

  void increaseLikes(int postId) {
    _postsService.incrementLikes(postId);
    update();
  }
}
