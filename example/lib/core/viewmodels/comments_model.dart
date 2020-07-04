import 'package:get/get.dart';
import 'package:get_stacked/get_stacked.dart';

import '../models/comment.dart';
import '../models/post.dart';
import '../services/api.dart';

class CommentsModel extends FutureGetController {
  List<Comment> comments;

  Api _api = Get.find<Api>();

  Post get post => Get.arguments;

  Future fetchComments(int postId) async {
    comments = await runBusyFuture(_api.getCommentsForPost(postId));
  }

  @override
  Future futureToRun() {
    return fetchComments(post.id);
  }
}
