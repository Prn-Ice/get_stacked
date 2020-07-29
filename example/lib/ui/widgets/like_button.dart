import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/viewmodels/like_button_model.dart';

class LikeButton extends StatelessWidget {
  final int postId;

  LikeButton({
    @required this.postId,
  });

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LikeButtonModel>(
      init: LikeButtonModel(),
      builder: (model) => Row(
        children: <Widget>[
          Text('Likes ${model.postLikes(postId)} '),
          MaterialButton(
            color: Colors.white,
            child: Icon(Icons.thumb_up),
            onPressed: () {
              model.increaseLikes(postId);
            },
          )
        ],
      ),
    );
  }
}
