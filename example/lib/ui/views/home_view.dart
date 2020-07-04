import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_only_example/core/models/post.dart';
import 'package:get_only_example/core/viewmodels/home_model.dart';
import 'package:get_only_example/ui/router.dart';
import 'package:get_only_example/ui/shared/app_colors.dart';
import 'package:get_only_example/ui/shared/text_styles.dart';
import 'package:get_only_example/ui/shared/ui_helpers.dart';
import 'package:get_only_example/ui/widgets/postlist_item.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<HomeModel>(
      builder: (model) => Scaffold(
        backgroundColor: backgroundColor,
        body: model.isBusy
            ? Center(child: CircularProgressIndicator())
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  UIHelper.verticalSpaceLarge(),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child: Text(
                      'Welcome ${model.user.name}',
                      style: headerStyle,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 20.0),
                    child:
                        Text('Here are all your posts', style: subHeaderStyle),
                  ),
                  UIHelper.verticalSpaceSmall(),
                  Expanded(child: getPostsUi(model.posts)),
                ],
              ),
      ),
    );
  }

  Widget getPostsUi(List<Post> posts) => ListView.builder(
        itemCount: posts.length,
        itemBuilder: (context, index) => PostListItem(
          post: posts[index],
          onTap: () {
            Get.toNamed(Router.postViewRoute, arguments: posts[index]);
          },
        ),
      );
}
