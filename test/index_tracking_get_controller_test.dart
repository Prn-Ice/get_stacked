import 'package:flutter_test/flutter_test.dart';
import 'package:get_stacked/get_stacked.dart';

void main() {
  group('IndexTrackingGetControllerTest -', () {
    group('setIndex -', () {
      test('When called with 1, should set currentIndex to 1', () {
        var controller = IndexTrackingGetController();
        controller.setIndex(1);
        expect(controller.currentIndex, 1);
      });

/*      test('When called with 1, should notifyListeners about update', () {
        var controller = IndexTrackingGetController();
        var called = false;
        controller.addListener(() {
          called = true;
        });
        controller.setIndex(1);
        expect(called, true);
      });*/

      test(
          'When called with 1 and currentIndex was 0, reverse should return false',
          () {
        var controller = IndexTrackingGetController();
        controller.setIndex(1);
        expect(controller.reverse, false);
      });

      test(
          'When called with 0 and currentIndex was 1, reverse should return true',
          () {
        var controller = IndexTrackingGetController();
        controller.setIndex(1);

        controller.setIndex(0);
        expect(controller.reverse, true);
      });

      test('When called with 1 isIndexSelected should return false for 0', () {
        var controller = IndexTrackingGetController();
        controller.setIndex(1);
        expect(controller.isIndexSelected(0), false);
      });

      test('When called with 1 isIndexSelected should return true for 1', () {
        var controller = IndexTrackingGetController();
        controller.setIndex(1);
        expect(controller.isIndexSelected(1), true);
      });
    });
  });
}
