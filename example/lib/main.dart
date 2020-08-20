import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_only_example/ui/views/test_view.dart';

import 'ui/router.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(),
      getPages: Router.namedRoutes,
      unknownRoute: Router.errorRoute,
    );
  }
}
