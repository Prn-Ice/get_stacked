import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../core/viewmodels/login_model.dart';
import '../router.dart';
import '../shared/app_colors.dart';
import '../widgets/login_header.dart';

class LoginView extends StatefulWidget {
  @override
  _LoginViewState createState() => _LoginViewState();
}

class _LoginViewState extends State<LoginView> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginModel>(
      init: LoginModel(),
      builder: (model) => Scaffold(
        backgroundColor: backgroundColor,
        body: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            LoginHeader(
                validationMessage: model.errorMessage, controller: _controller),
            model.isBusy
                ? CircularProgressIndicator()
                : FlatButton(
                    color: Colors.white,
                    child: Text(
                      'Login',
                      style: TextStyle(color: Colors.black),
                    ),
                    onPressed: () async {
                      var loginSuccess = await model.login(_controller.text);
                      if (loginSuccess) {
                        Get.toNamed(Router.homeViewRoute);
                      }
                    },
                  )
          ],
        ),
      ),
    );
  }
}
