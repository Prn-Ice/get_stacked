import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_only_example/ui/shared/ui_helpers.dart';

import '../../core/viewmodels/test_view_model.dart';

class TestView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestViewModel>(
      init: TestViewModel(),
      builder: (_) => Scaffold(
        appBar: AppBar(
          title: Text('This is a test'),
        ),
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _.fetchingInt
                ? Center(child: CircularProgressIndicator())
                : Text('Int Val: ${_.fetchedNumber}'),
            UIHelper.verticalSpaceLarge(),
            _.fetchingString
                ? Center(child: CircularProgressIndicator())
                : Text('String val: ${_.fetchedString}'),
          ],
        ),
      ),
    );
  }
}
