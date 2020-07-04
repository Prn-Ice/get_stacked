import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_only_example/core/viewmodels/post_model.dart';
import 'package:get_only_example/ui/shared/app_colors.dart';
import 'package:get_only_example/ui/shared/text_styles.dart';
import 'package:get_only_example/ui/shared/ui_helpers.dart';
import 'package:get_only_example/ui/widgets/comments.dart';
import 'package:get_only_example/ui/widgets/like_button.dart';

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
