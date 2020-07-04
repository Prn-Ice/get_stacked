import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_only_example/core/viewmodels/test_view_model.dart';

class TestView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestViewModel>(
      init: TestViewModel(),
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text('This is a test'),
        ),
        body: Container(
          child: Center(
            child: _.isBusy ? CircularProgressIndicator() : Text('${_.data}'),
          ),
        ),
      ),
    );
  }
}
