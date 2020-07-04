import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_only_example/core/models/comment.dart';
import 'package:get_only_example/core/viewmodels/comments_model.dart';
import 'package:get_only_example/ui/shared/app_colors.dart';
import 'package:get_only_example/ui/shared/ui_helpers.dart';

class Comments extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<CommentsModel>(
      init: CommentsModel(),
      builder: (model) {
        return model.isBusy
            ? Center(child: CircularProgressIndicator())
            : Expanded(
                child: ListView(
                  children: model.comments
                          ?.map((comment) => CommentItem(comment))
                          ?.toList() ??
                      [Text('no data')],
                ),
              );
      },
    );
  }
}

/// Renders a single comment given a comment model
class CommentItem extends StatelessWidget {
  final Comment comment;
  const CommentItem(this.comment);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(10.0),
      margin: EdgeInsets.symmetric(vertical: 10.0),
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10.0), color: commentColor),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            comment.name,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          UIHelper.verticalSpaceSmall(),
          Text(comment.body),
        ],
      ),
    );
  }
}
