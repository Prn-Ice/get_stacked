import 'package:get/get.dart';
import 'package:get_stacked/get_stacked.dart';

import '../services/posts_service.dart';

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
