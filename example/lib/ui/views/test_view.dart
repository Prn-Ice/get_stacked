import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/viewmodels/test_view_model.dart';

class TestView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: AppBar(
          title: Text('This is a test'),
          bottom: TabBar(
            labelPadding: EdgeInsets.symmetric(vertical: 10),
            tabs: [
              Text('Tab 1'),
              Text('Tab 2'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _Tab1(),
            _Tab2(),
          ],
        ),
      ),
    );
  }
}

class _Tab2 extends StatelessWidget {
  const _Tab2({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestViewModel>(
      init: TestViewModel(),
      global: false,
      builder: (viewModel) {
        return Center(
          child: viewModel.loading
              ? CircularProgressIndicator()
              : Text(viewModel.text),
        );
      },
    );
  }
}

class _Tab1 extends StatelessWidget {
  const _Tab1({
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder<TestViewModel>(
      init: TestViewModel(),
      global: false,
      builder: (viewModel) {
        return Center(
          child: viewModel.loading
              ? CircularProgressIndicator()
              : Text(viewModel.text),
        );
      },
    );
  }
}
