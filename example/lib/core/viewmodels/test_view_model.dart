import 'package:get/get.dart';

class TestViewModel extends GetxController {
  static TestViewModel get to => Get.find();

  String text = 'if this shows, onInit did not run';
  bool _loading = false;

  bool get loading => _loading;

  set loading(bool value) {
    _loading = value;
    update();
  }

  @override
  Future<void> onInit() async {
    print('passing on onInit');
    super.onInit();
    loading = true;
    await Future.delayed(Duration(seconds: 1));
    text = 'hello';
    loading = false;
  }
}
