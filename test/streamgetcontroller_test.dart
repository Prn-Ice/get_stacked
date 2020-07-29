import 'package:flutter_test/flutter_test.dart';
import 'package:get_stacked/get_stacked.dart';

Stream<int> numberStream(int dataBack, {bool fail, int delay}) async* {
  if (fail) throw Exception('numberStream failed');
  if (delay != null) await Future.delayed(Duration(milliseconds: delay));
  yield dataBack;
}

Stream<String> textStream(String dataBack, {bool fail, int delay}) async* {
  if (fail) throw Exception('textStream failed');
  if (delay != null) await Future.delayed(Duration(milliseconds: delay));
  yield dataBack;
}

class TestStreamGetController extends StreamGetController<int> {
  final bool fail;
  final int delay;
  TestStreamGetController({this.fail = false, this.delay = 0});
  int loadedData;

  @override
  get stream => numberStream(1, fail: fail, delay: delay);

  @override
  void onData(int data) {
    loadedData = data;
  }
}

const String _NumberStream = 'numberStream';
const String _StringStream = 'stringStream';

class TestMultipleStreamGetController extends MultipleStreamGetController {
  final bool failOne;
  final int delay;
  TestMultipleStreamGetController({this.failOne = false, this.delay = 0});
  int loadedData;
  int cancelledCalls = 0;
  @override
  Map<String, StreamData> get streamsMap => {
        _NumberStream: StreamData(numberStream(
          5,
          fail: failOne,
          delay: delay,
        )),
        _StringStream: StreamData(textStream(
          "five",
          fail: false,
          delay: delay,
        )),
      };

  @override
  void onCancel(String key) {
    cancelledCalls++;
  }
}

class TestMultipleStreamGetControllerWithOverrides
    extends MultipleStreamGetController {
  TestMultipleStreamGetControllerWithOverrides();
  int loadedData;
  @override
  Map<String, StreamData> get streamsMap => {
        _NumberStream: StreamData(
          numberStream(5, fail: false, delay: 0),
          onData: _loadData,
        )
      };

  void _loadData(data) {
    loadedData = data;
  }
}

void main() async {
  group('StreamGetController', () {
    test('When stream data is fetched data should be set and ready', () async {
      var streamGetController = TestStreamGetController();
      streamGetController.initialise();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamGetController.data, 1);
      expect(streamGetController.dataReady, true);
    });
    test('When stream lifecycle events are overriden they recieve correct data',
        () async {
      var streamGetController = TestStreamGetController();
      streamGetController.initialise();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamGetController.loadedData, 1);
    });

    test('When a stream fails it should indicate there\'s an error and no data',
        () async {
      var streamGetController = TestStreamGetController(fail: true);
      streamGetController.initialise();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamGetController.hasError, true);
      expect(streamGetController.data, null,
          reason: 'No data should be set when there\'s a failure.');
      expect(streamGetController.dataReady, false);
    });

    test('Before a stream returns it should indicate not ready', () async {
      var streamGetController = TestStreamGetController(delay: 1000);
      streamGetController.initialise();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamGetController.dataReady, false);
    });

/*    test('When a stream returns it should notifyListeners', () async {
      var streamGetController = TestStreamGetController(delay: 50);
      var listenersCalled = false;
      streamGetController.addListener(() {
        listenersCalled = true;
      });
      streamGetController.initialise();
      await Future.delayed(Duration(milliseconds: 100));
      expect(listenersCalled, true);
    });*/

    group('Data Source Change', () {
      test(
          'notifySourceChanged - When called should unsubscribe from original source',
          () {
        var streamGetController = TestStreamGetController(delay: 1000);
        streamGetController.initialise();
        streamGetController.notifySourceChanged();

        expect(streamGetController.streamSubscription, null);
      });

      test(
          'notifySourceChanged - When called and clearOldData is false should leave old data',
          () async {
        var streamGetController = TestStreamGetController(delay: 10);
        streamGetController.initialise();

        await Future.delayed(const Duration(milliseconds: 20));
        streamGetController.notifySourceChanged();

        expect(streamGetController.data, 1);
      });

      test(
          'notifySourceChanged - When called and clearOldData is true should remove old data',
          () async {
        var streamGetController = TestStreamGetController(delay: 10);
        streamGetController.initialise();

        await Future.delayed(const Duration(milliseconds: 20));
        streamGetController.notifySourceChanged(clearOldData: true);

        expect(streamGetController.data, null);
      });
    });
  });

  group('MultipleStreamGetController', () {
    test(
        'When running multiple streams the associated key should hold the value when data is fetched',
        () async {
      var streamGetController = TestMultipleStreamGetController();
      streamGetController.initialise();
      await Future.delayed(Duration(milliseconds: 4));
      expect(streamGetController.dataMap[_NumberStream], 5);
      expect(streamGetController.dataMap[_StringStream], 'five');
    });

    test(
        'When one of multiple streams fail only the failing one should have an error',
        () async {
      var streamGetController = TestMultipleStreamGetController(failOne: true);
      streamGetController.initialise();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamGetController.hasErrorForKey(_NumberStream), true);
      // Make sure we only have 1 error
      // expect(streamGetController.errorMap.values.where((v) => v == true).length, 1);
    });

    test(
        'When one of multiple streams fail the passed one should have data and failing one not',
        () async {
      var streamGetController = TestMultipleStreamGetController(failOne: true);
      streamGetController.initialise();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamGetController.dataReady(_NumberStream), false);
      // Delay the first lifecycle can complete
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamGetController.dataReady(_StringStream), true);
    });

    test('When one onData is augmented the data will change', () async {
      var streamGetController = TestMultipleStreamGetControllerWithOverrides();
      streamGetController.initialise();
      await Future.delayed(Duration(milliseconds: 1));
      expect(streamGetController.loadedData, 5);
    });

/*    test('When a stream returns it should notifyListeners', () async {
      var streamGetController = TestMultipleStreamGetController(delay: 50);
      var listenersCalled = false;
      streamGetController.addListener(() {
        listenersCalled = true;
      });
      streamGetController.initialise();
      await Future.delayed(Duration(milliseconds: 100));
      expect(listenersCalled, true);
    });*/

    test(
        'When a stream is initialised should have a subscription for the given key',
        () async {
      var streamGetController = TestMultipleStreamGetController();

      streamGetController.initialise();
      expect(streamGetController.getSubscriptionForKey(_NumberStream) != null,
          true);
    });

    test('When disposed, should call onCancel for both streams', () async {
      var streamGetController = TestMultipleStreamGetController();

      streamGetController.initialise();
      streamGetController.onClose();
      expect(streamGetController.cancelledCalls, 2);
    });
  });

  group('Data Source Change', () {
    test(
        'notifySourceChanged - When called should unsubscribe from original sources',
        () {
      var streamGetController = TestMultipleStreamGetController(delay: 50);
      streamGetController.initialise();
      streamGetController.notifySourceChanged();

      expect(streamGetController.streamsSubscriptions.length, 0);
    });

    test(
        'notifySourceChanged - When called and clearOldData is false should leave old data',
        () async {
      var streamGetController = TestMultipleStreamGetController(delay: 10);
      streamGetController.initialise();

      await Future.delayed(const Duration(milliseconds: 20));
      streamGetController.notifySourceChanged();

      expect(streamGetController.dataMap[_NumberStream], 5);
    });

    test(
        'notifySourceChanged - When called and clearOldData is true should remove old data',
        () async {
      var streamGetController = TestMultipleStreamGetController(delay: 10);
      streamGetController.initialise();

      await Future.delayed(const Duration(milliseconds: 20));
      streamGetController.notifySourceChanged(clearOldData: true);

      expect(streamGetController.dataMap[_NumberStream], null);
    });
  });
}
