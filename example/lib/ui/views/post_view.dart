import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/viewmodels/post_model.dart';
import '../shared/app_colors.dart';
import '../shared/text_styles.dart';
import '../shared/ui_helpers.dart';
import '../widgets/comments.dart';
import '../widgets/like_button.dart';

class PostView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<PostModel>(
      builder: (model) => Scaffold(
        backgroundColor: backgroundColor,
        body: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              UIHelper.verticalSpaceLarge(),
              Text(model.post.title, style: headerStyle),
              Text(
                'by ${model.user.name}',
                style: TextStyle(fontSize: 9.0),
              ),
              UIHelper.verticalSpaceMedium(),
              Text(model.post.body),
              LikeButton(
                postId: model.post.id,
              ),
              Comments(),
            ],
          ),
        ),
      ),
    );
  }
}
