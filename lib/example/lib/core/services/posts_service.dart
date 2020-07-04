import 'package:get/get.dart';
import 'package:get_only_example/core/models/post.dart';
import 'package:get_only_example/core/services/api.dart';

class PostsService {
  Api _api = Get.find<Api>();

  List<Post> _posts;
  List<Post> get posts => _posts;

  Future getPostsForUser(int userId) async {
    _posts = await _api.getPostsForUser(userId);
  }

  void incrementLikes(int postId){
    _posts.firstWhere((post) => post.id == postId).likes.value++;
  }
} 