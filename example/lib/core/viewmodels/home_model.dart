import 'package:get/get.dart';
import 'package:get_stacked/get_stacked.dart';

import '../models/post.dart';
import '../models/user.dart';
import '../services/authentication_service.dart';
import '../services/posts_service.dart';

class HomeModel extends FutureGetController {
  PostsService _postsService = Get.find<PostsService>();

  List<Post> get posts => _postsService.posts;

  User get user => Get.find<AuthenticationService>().userController.value;

  @override
  Future futureToRun() {
    return _postsService.getPostsForUser(user.id);
  }
}
