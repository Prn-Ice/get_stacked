import 'package:flutter_test/flutter_test.dart';
import 'package:get_stacked/get_stacked.dart';

class TestGetController extends BaseGetController {
  bool onErrorCalled = false;
  Future runFuture(
      {String busyKey, bool fail = false, bool throwException = false}) {
    return runBusyFuture(
      _futureToRun(fail),
      busyObject: busyKey,
      throwException: throwException,
    );
  }

  Future runTestErrorFuture(
      {String key, bool fail = false, bool throwException = false}) {
    return runErrorFuture(
      _futureToRun(fail),
      key: key,
      throwException: throwException,
    );
  }

  Future _futureToRun(bool fail) async {
    await Future.delayed(Duration(milliseconds: 50));
    if (fail) {
      throw Exception('Broken Future');
    }
  }

  @override
  void onFutureError(error, key) {
    onErrorCalled = true;
  }
}

void main() {
  group('BaseGetController Tests -', () {
    group('Busy functionality -', () {
      test('When setBusy is called with true isBusy should be true', () {
        var controller = TestGetController();
        controller.setBusy(true);
        expect(controller.isBusy, true);
      });

      test(
          'When setBusyForObject is called with parameter true busy for that object should be true',
          () {
        var property;
        var controller = TestGetController();
        controller.setBusyForObject(property, true);
        expect(controller.busy(property), true);
      });

      test(
          'When setBusyForObject is called with true then false, should be false',
          () {
        var property;
        var controller = TestGetController();
        controller.setBusyForObject(property, true);
        controller.setBusyForObject(property, false);
        expect(controller.busy(property), false);
      });

      test('When busyFuture is run should report busy for the model', () {
        var controller = TestGetController();
        controller.runFuture();
        expect(controller.isBusy, true);
      });

      test(
          'When busyFuture is run with busyObject should report busy for the Object',
          () {
        var busyObjectKey = 'busyObjectKey';
        var controller = TestGetController();
        controller.runFuture(busyKey: busyObjectKey);
        expect(controller.busy(busyObjectKey), true);
      });

      test(
          'When busyFuture is run with busyObject should report NOT busy when error is thrown',
          () async {
        var busyObjectKey = 'busyObjectKey';
        var controller = TestGetController();
        await controller.runFuture(busyKey: busyObjectKey, fail: true);
        expect(controller.busy(busyObjectKey), false);
      });

      test(
          'When busyFuture is run with busyObject should throw exception if throwException is set to true',
          () async {
        var busyObjectKey = 'busyObjectKey';
        var controller = TestGetController();

        expect(
            () async => await controller.runFuture(
                busyKey: busyObjectKey, fail: true, throwException: true),
            throwsException);
      });

      /*test(
          'When busy future is complete should have called update twice, 1 for busy 1 for not busy',
          () async {
        var called = 0;
        var controller = TestGetController();
        controller.addListener(() {
          ++called;
        });
        await controller.runFuture(fail: true);
        expect(called, 2);
      });*/

      test('When update is called before onClose, should not throw exception',
          () async {
        var controller = TestGetController();
        await controller.runFuture();
        controller.update();
        controller.onClose();
        expect(() => controller.update(), returnsNormally);
      });

      test('When update is called after onClose, should not throw exception',
          () async {
        var controller = TestGetController();
        await controller.runFuture();
        controller.onClose();
        controller.update();
        expect(() => controller.update(), returnsNormally);
      });
    });

    group('runErrorFuture -', () {
      test('When called and error is thrown should set error', () async {
        var controller = TestGetController();
        await controller.runTestErrorFuture(fail: true);
        expect(controller.hasError, true);
      });
      test(
          'When called and error is thrown should call onErrorForFuture override',
          () async {
        var controller = TestGetController();
        await controller.runTestErrorFuture(fail: true, throwException: false);
        expect(controller.onErrorCalled, true);
      });
    });
  });
}
