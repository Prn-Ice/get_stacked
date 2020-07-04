import 'package:get/get.dart';
import 'package:get_only_example/core/models/comment.dart';
import 'package:get_only_example/core/models/post.dart';
import 'package:get_only_example/core/services/api.dart';
import 'package:get_stacked/get_stacked.dart';


class CommentsModel extends FutureGetController {
  List<Comment> comments;

  Api _api = Get.find<Api>();

  /*@override
  void onInit() {
    fetchComments(post.id);
    super.onInit();
  }*/

  Post get post => Get.arguments;

  Future fetchComments(int postId) async {
    comments = await runBusyFuture(_api.getCommentsForPost(postId));
  }

  @override
  Future futureToRun() {
    return fetchComments(post.id);
  }
}
