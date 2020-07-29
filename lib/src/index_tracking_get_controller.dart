import 'package:get/get.dart';
import 'package:get_stacked/src/base_controllers.dart';

class IndexTrackingGetController extends BaseGetController {
  final RxInt _currentIndex = 0.obs;
  int get currentIndex => _currentIndex.value;

  final RxBool _reverse = false.obs;

  /// Indicates whether we're going forward or backward in terms of the index we're changing.
  /// This is very helpful for the page transition directions.
  bool get reverse => _reverse.value;

  void setIndex(int value) {
    if (value < _currentIndex.value) {
      _reverse.value = true;
    } else {
      _reverse.value = false;
    }
    _currentIndex.value = value;
    update();
  }

  bool isIndexSelected(int index) => _currentIndex.value == index;
}
