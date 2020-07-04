import 'package:get/get.dart';

class Post {
  int userId;
  int id;
  String title;
  String body;
  RxInt likes;

  Post({this.userId, this.id, this.title, this.body}) : likes = 0.obs;

  Post.fromJson(Map<String, dynamic> json) {
    userId = json['userId'];
    id = json['id'];
    title = json['title'];
    body = json['body'];
    likes = 0.obs;
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['userId'] = this.userId;
    data['id'] = this.id;
    data['title'] = this.title;
    data['body'] = this.body;
    return data;
  }
}
