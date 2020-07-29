import 'package:flutter_test/flutter_test.dart';
import 'package:get_stacked/get_stacked.dart';

const _SingleFutureExceptionFailMessage = 'Future to Run failed';

class TestFutureGetController extends FutureGetController<int> {
  final bool fail;
  TestFutureGetController({this.fail = false});

  int numberToReturn = 5;
  bool dataCalled = false;

  @override
  Future<int> futureToRun() async {
    if (fail) throw Exception(_SingleFutureExceptionFailMessage);
    await Future.delayed(Duration(milliseconds: 20));
    return numberToReturn;
  }

  @override
  void onData(int data) {
    dataCalled = true;
  }
}

const String NumberDelayFuture = 'delayedNumber';
const String StringDelayFuture = 'delayedString';
const String _NumberDelayExceptionMessage = 'getNumberAfterDelay failed';

class TestMultipleFutureGetController extends MultipleFutureGetController {
  final bool failOne;
  final int futureOneDuration;
  final int futureTwoDuration;
  TestMultipleFutureGetController(
      {this.failOne = false,
      this.futureOneDuration = 300,
      this.futureTwoDuration = 400});

  int numberToReturn = 5;

  @override
  Map<String, Future Function()> get futuresMap => {
        NumberDelayFuture: getNumberAfterDelay,
        StringDelayFuture: getStringAfterDelay,
      };

  Future<int> getNumberAfterDelay() async {
    if (failOne) {
      throw Exception(_NumberDelayExceptionMessage);
    }
    await Future.delayed(Duration(milliseconds: futureOneDuration));
    return numberToReturn;
  }

  Future<String> getStringAfterDelay() async {
    await Future.delayed(Duration(milliseconds: futureTwoDuration));
    return 'String data';
  }
}

void main() {
  group('FutureGetController', () {
    test('When future is complete data should be set and ready', () async {
      var futureGetController = TestFutureGetController();
      await futureGetController.initialise();
      expect(futureGetController.data, 5);
      expect(futureGetController.dataReady, true);
    });

    test('When a future fails it should indicate there\'s an error and no data',
        () async {
      var futureGetController = TestFutureGetController(fail: true);
      await futureGetController.initialise();
      expect(futureGetController.hasError, true);
      expect(futureGetController.data, null,
          reason: 'No data should be set when there\'s a failure.');
      expect(futureGetController.dataReady, false);
    });

    test('When a future runs it should indicate busy', () async {
      var futureGetController = TestFutureGetController();
      futureGetController.initialise();
      expect(futureGetController.isBusy, true);
    });

    test('When a future fails it should indicate NOT busy', () async {
      var futureGetController = TestFutureGetController(fail: true);
      await futureGetController.initialise();
      expect(futureGetController.isBusy, false);
    });

    test('When a future fails it should set error to exception', () async {
      var futureGetController = TestFutureGetController(fail: true);
      await futureGetController.initialise();
      expect(futureGetController.modelError.message,
          _SingleFutureExceptionFailMessage);
    });

    test('When a future fails onData should not be called', () async {
      var futureGetController = TestFutureGetController(fail: true);
      await futureGetController.initialise();
      expect(futureGetController.dataCalled, false);
    });

    test('When a future passes onData should not called', () async {
      var futureGetController = TestFutureGetController();
      await futureGetController.initialise();
      expect(futureGetController.dataCalled, true);
    });

    group('Dynamic Source Tests', () {
      test('notifySourceChanged - When called should re-run Future', () async {
        var futureGetController = TestFutureGetController();
        await futureGetController.initialise();
        expect(futureGetController.data, 5);
        futureGetController.numberToReturn = 10;
        futureGetController.notifySourceChanged();
        await futureGetController.initialise();
        expect(futureGetController.data, 10);
      });
    });
  });

  group('MultipleFutureGetController -', () {
    test(
        'When running multiple futures the associated key should hold the value when complete',
        () async {
      var futureGetController = TestMultipleFutureGetController();
      await futureGetController.initialise();

      expect(futureGetController.dataMap[NumberDelayFuture], 5);
      expect(futureGetController.dataMap[StringDelayFuture], 'String data');
    });

    test(
        'When one of multiple futures fail only the failing one should have an error',
        () async {
      var futureGetController = TestMultipleFutureGetController(failOne: true);
      await futureGetController.initialise();

      expect(futureGetController.hasErrorForKey(NumberDelayFuture), true);
      expect(futureGetController.hasErrorForKey(StringDelayFuture), false);
    });

    test(
        'When one of multiple futures fail the passed one should have data and failing one not',
        () async {
      var futureGetController = TestMultipleFutureGetController(failOne: true);
      await futureGetController.initialise();

      expect(futureGetController.dataMap[NumberDelayFuture], null);
      expect(futureGetController.dataMap[StringDelayFuture], 'String data');
    });

    test('When multiple futures run the key should be set to indicate busy',
        () async {
      var futureGetController = TestMultipleFutureGetController();
      futureGetController.initialise();

      expect(futureGetController.busy(NumberDelayFuture), true);
      expect(futureGetController.busy(StringDelayFuture), true);
    });

    test(
        'When multiple futures are complete the key should be set to indicate NOT busy',
        () async {
      var futureGetController = TestMultipleFutureGetController();
      await futureGetController.initialise();

      expect(futureGetController.busy(NumberDelayFuture), false);
      expect(futureGetController.busy(StringDelayFuture), false);
    });

    test('When a future fails busy should be set to false', () async {
      var futureGetController = TestMultipleFutureGetController(failOne: true);
      await futureGetController.initialise();

      expect(futureGetController.busy(NumberDelayFuture), false);
      expect(futureGetController.busy(StringDelayFuture), false);
    });

    test('When a future fails should set error for future key', () async {
      var futureGetController = TestMultipleFutureGetController(failOne: true);
      await futureGetController.initialise();

      expect(futureGetController.error(NumberDelayFuture).message,
          _NumberDelayExceptionMessage);

      expect(futureGetController.error(StringDelayFuture), null);
    });

    test(
        'When 1 future is still running out of two anyObjectsBusy should return true',
        () async {
      var futureGetController = TestMultipleFutureGetController(
          futureOneDuration: 10, futureTwoDuration: 60);
      futureGetController.initialise();
      await Future.delayed(Duration(milliseconds: 30));

      expect(futureGetController.busy(NumberDelayFuture), false,
          reason: 'String future should be done at this point');
      expect(futureGetController.anyObjectsBusy, true,
          reason: 'Should be true because second future is still running');
    });

    group('Dynamic Source Tests', () {
      test('notifySourceChanged - When called should re-run Future', () async {
        var futureGetController = TestMultipleFutureGetController();
        await futureGetController.initialise();
        expect(futureGetController.dataMap[NumberDelayFuture], 5);
        futureGetController.numberToReturn = 10;
        futureGetController.notifySourceChanged();
        await futureGetController.initialise();
        expect(futureGetController.dataMap[NumberDelayFuture], 10);
      });
    });
  });
}
