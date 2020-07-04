import 'package:get/get.dart';
import 'package:get_only_example/core/models/post.dart';
import 'package:get_only_example/core/models/user.dart';
import 'package:get_only_example/core/services/authentication_service.dart';
import 'package:get_only_example/core/services/posts_service.dart';
import 'package:get_stacked/get_stacked.dart';

class HomeModel extends FutureGetController {
  PostsService _postsService = Get.find<PostsService>();

  List<Post> get posts => _postsService.posts;

  User get user => Get.find<AuthenticationService>().userController.value;

  @override
  Future futureToRun() {
    return _postsService.getPostsForUser(user.id);
  }
}
