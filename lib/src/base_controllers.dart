import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

/// Contains ViewModel functionality for busy state management
class BaseGetController extends GetxController {
  Map<int, bool> _busyStates = <int, bool>{};

  bool _disposed = false;

  /// Whether or not this model is disposed.
  bool get disposed => _disposed;

  /// Returns the busy status for an object if it exists.
  /// Returns false if not present
  bool busy(Object object) => _busyStates[object.hashCode] ?? false;

  /// Returns the busy status of the viewmodel
  bool get isBusy => busy(this);

  /// Returns true if any objects still have a busy status that is true.
  bool get anyObjectsBusy => _busyStates.values.any((busy) => busy);

  /// Marks the viewmodel as busy and calls notify listeners
  // ignore: avoid_positional_boolean_parameters
  void setBusy(bool value) {
    setBusyForObject(this, value);
  }

  /// Sets the busy state for the object equal to the value passed in
  /// and notifies Listeners
  ///
  /// If you're using a primitive type the value SHOULD NOT BE CHANGED,
  /// since Hashcode uses == value
  // ignore: avoid_positional_boolean_parameters
  void setBusyForObject(Object object, bool value) {
    _busyStates[object.hashCode] = value;
    update();
  }

  /// Sets the ViewModel to busy, runs the future and then sets it to not busy
  /// when complete.
  ///
  /// rethrows [Exception] after setting busy to false for object or class
  Future runBusyFuture(Future busyFuture,
      {Object busyObject, bool throwException = false}) async {
    _setBusyForModelOrObject(true, busyObject: busyObject);
    try {
      var value = await busyFuture;
      _setBusyForModelOrObject(false, busyObject: busyObject);
      return value;
      // ignore: avoid_catches_without_on_clauses
    } catch (e) {
      _setBusyForModelOrObject(false, busyObject: busyObject);
      if (throwException) rethrow;
    }
  }

  void _setBusyForModelOrObject(bool value, {Object busyObject}) {
    if (busyObject != null) {
      setBusyForObject(busyObject, value);
    } else {
      setBusyForObject(this, value);
    }
  }

  /// Sets up streamData property to hold data, busy, and lifecycle events
  @protected
  StreamData setupStream<T>(
    Stream<T> stream, {
    // ignore: type_annotate_public_apis
    onData,
    // ignore: type_annotate_public_apis
    onSubscribed,
    // ignore: type_annotate_public_apis
    onError,
    // ignore: type_annotate_public_apis
    onCancel,
    // ignore: type_annotate_public_apis
    transformData,
  }) {
    var streamData = StreamData<T>(
      stream,
      onData: onData,
      onSubscribed: onSubscribed,
      onError: onError,
      onCancel: onCancel,
      transformData: transformData,
    );
    streamData.initialise();

    return streamData;
  }

  @override
  void update([List<String> ids, bool condition = true]) {
    if (!disposed) {
      super.update();
    }
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }
}

@protected
// ignore: public_member_api_docs
class DynamicSourceGetController<T> extends BaseGetController {
  // ignore: public_member_api_docs
  bool changeSource = false;
  // ignore: public_member_api_docs
  void notifySourceChanged({bool clearOldData = false}) {
    changeSource = true;
  }
}

class _SingleDataSourceGetController<T> extends DynamicSourceGetController {
  T _data;
  T get data => _data;

  bool _hasError;
  bool get hasError => _hasError;

  dynamic _error;
  dynamic get error => _error;

  bool get dataReady => _data != null && !_hasError;
}

class _MultiDataSourceGetController extends DynamicSourceGetController {
  Map<String, dynamic> _dataMap;
  Map<String, dynamic> get dataMap => _dataMap;

  Map<String, bool> _errorMap;

  Map<String, dynamic> _errors;
  dynamic getError(String key) => _errors[key];

  bool hasError(String key) => _errorMap[key] ?? false;
  bool dataReady(String key) =>
      _dataMap[key] != null && (_errorMap[key] == null);
}

/// Provides functionality for a ViewModel that's sole purpose it is to fetch
/// data using a [Future]
abstract class FutureGetController<T>
    extends _SingleDataSourceGetController<T> {
  /// The future that fetches the data and sets the view to busy
  @Deprecated('Use the futureToRun function')
  Future<T> get future => null;

  // TODO: Add timeout functionality
  // TODO: Add retry functionality - default 1
  // TODO: Add retry lifecycle hooks to override in the viewmodel

  // ignore: public_member_api_docs
  Future<T> futureToRun();

  Future initialise() async {
    _hasError = false;
    _error = null;
    // We set busy manually as well because when notify listeners is called to
    // clear error messages the
    // ui is rebuilt and if you expect busy to be true it's not.
    setBusy(true);
    update();

    _data = await runBusyFuture(futureToRun(), throwException: true)
        .catchError((error) {
      _hasError = true;
      _error = error;
      setBusy(false);
      onError(error);
      update();
    });

    if (_data != null) {
      onData(_data);
    }

    changeSource = false;
  }

  /// Called when an error occurs within the future being run
  void onError(error) {}

  /// Called after the data has been set
  void onData(T data) {}

  @override
  void onInit() {
    initialise();
    super.onInit();
  }
}

/// Provides functionality for a ViewModel to run and fetch data using multiple
/// future
abstract class MultipleFutureGetController
    extends _MultiDataSourceGetController {
  // ignore: public_member_api_docs
  Map<String, Future Function()> get futuresMap;

  Completer _futuresCompleter;
  int _futuresCompleted;

  void _initialiseData() {
    if (_errorMap == null) {
      _errorMap = <String, bool>{};
    }
    if (_dataMap == null) {
      _dataMap = <String, dynamic>{};
    }
    if (_errors == null) {
      _errors = <String, dynamic>{};
    }

    _futuresCompleted = 0;
  }

  Future initialise() {
    _futuresCompleter = Completer();
    _initialiseData();
    // We set busy manually as well because when notify listeners is called to
    // clear error messages the
    // ui is rebuilt and if you expect busy to be true it's not.
    setBusy(true);
    update();

    for (var key in futuresMap.keys) {
      runBusyFuture(futuresMap[key](), busyObject: key, throwException: true)
          .then((futureData) {
        _dataMap[key] = futureData;
        setBusyForObject(key, false);
        update();
        onData(key);
        _incrementAndCheckFuturesCompleted();
      }).catchError((error) {
        _errorMap[key] = true;
        _errors[key] = error;
        setBusyForObject(key, false);
        onError(key: key, error: error);
        update();
        _incrementAndCheckFuturesCompleted();
      });
    }

    changeSource = false;

    return _futuresCompleter.future;
  }

  void _incrementAndCheckFuturesCompleted() {
    _futuresCompleted++;
    if (_futuresCompleted == futuresMap.length &&
        !_futuresCompleter.isCompleted) {
      _futuresCompleter.complete();
    }
  }

  // ignore: public_member_api_docs, type_annotate_public_apis
  void onError({String key, error}) {}

  // ignore: public_member_api_docs
  void onData(String key) {}

  @override
  void onInit() {
    initialise();
    super.onInit();
  }
}

/// Provides functionality for a ViewModel to run and fetch data
/// using multiple streams
abstract class MultipleStreamGetController
    extends _MultiDataSourceGetController {
  // Every MultipleStreamViewModel must override streamDataMap
  // StreamData requires a stream, but lifecycle events are optional
  // if a lifecyle event isn't defined we use the default ones here
  // ignore: public_member_api_docs
  Map<String, StreamData> get streamsMap;

  Map<String, StreamSubscription> _streamsSubscriptions;

  @visibleForTesting
  // ignore: public_member_api_docs
  Map<String, StreamSubscription> get streamsSubscriptions =>
      _streamsSubscriptions;

  /// Returns the stream subscription associated with the key
  StreamSubscription getSubscriptionForKey(String key) =>
      _streamsSubscriptions[key];

  void initialise() {
    _dataMap = <String, dynamic>{};
    _errorMap = <String, bool>{};
    _errors = <String, dynamic>{};
    _streamsSubscriptions = <String, StreamSubscription>{};

    if (!changeSource) {
      update();
    }

    for (var key in streamsMap.keys) {
      // If a lifecycle function isn't supplied, we fallback to default
      _streamsSubscriptions[key] = streamsMap[key].stream.listen(
        (incomingData) {
          _errorMap.remove(key);
          _errors.remove(key);
          update();
          // Extra security in case transformData isnt sent
          var interceptedData = streamsMap[key].transformData == null
              ? transformData(key, incomingData)
              : streamsMap[key].transformData(incomingData);

          if (interceptedData != null) {
            _dataMap[key] = interceptedData;
          } else {
            _dataMap[key] = incomingData;
          }

          update();
          streamsMap[key].onData != null
              ? streamsMap[key].onData(_dataMap[key])
              : onData(key, _dataMap[key]);
        },
        onError: (error) {
          _errorMap[key] = true;
          _errors[key] = error;
          _dataMap[key] = null;

          streamsMap[key].onError != null
              ? streamsMap[key].onError(error)
              : onError(key, error);
          update();
        },
      );
      streamsMap[key].onSubscribed != null
          ? streamsMap[key].onSubscribed()
          : onSubscribed(key);
      changeSource = false;
    }
  }

  @override
  void notifySourceChanged({bool clearOldData = false}) {
    changeSource = true;
    _disposeAllSubscriptions();

    if (clearOldData) {
      dataMap.clear();
      _errorMap.clear();
      _errors.clear();
    }

    update();
  }

  // ignore: public_member_api_docs
  void onData(String key, dynamic data) {}
  // ignore: public_member_api_docs
  void onSubscribed(String key) {}
  // ignore: public_member_api_docs, type_annotate_public_apis
  void onError(String key, error) {}
  // ignore: public_member_api_docs
  void onCancel(String key) {}
  // ignore: public_member_api_docs, type_annotate_public_apis
  dynamic transformData(String key, data) {
    return data;
  }

  @override
  @mustCallSuper
  void onClose() {
    _disposeAllSubscriptions();
    super.onClose();
  }

  void _disposeAllSubscriptions() {
    if (_streamsSubscriptions != null) {
      for (var key in _streamsSubscriptions.keys) {
        _streamsSubscriptions[key].cancel();
      }

      _streamsSubscriptions.clear();
    }
  }

  @override
  void onInit() {
    initialise();
    super.onInit();
  }
}

// ignore: public_member_api_docs
abstract class StreamGetController<T> extends _SingleDataSourceGetController<T>
    implements DynamicSourceGetController {
  /// Stream to listen to
  Stream<T> get stream;

  // ignore: public_member_api_docs
  StreamSubscription get streamSubscription => _streamSubscription;

  StreamSubscription _streamSubscription;

  @override
  void notifySourceChanged({bool clearOldData = false}) {
    changeSource = true;
    _streamSubscription?.cancel();
    _streamSubscription = null;

    if (clearOldData) {
      _data = null;
    }

    update();
  }

  void initialise() {
    _streamSubscription = stream.listen(
      (incomingData) {
        _hasError = false;
        _error = null;
        update();
        // Extra security in case transformData isnt sent
        var interceptedData =
            transformData == null ? incomingData : transformData(incomingData);

        if (interceptedData != null) {
          _data = interceptedData;
        } else {
          _data = incomingData;
        }

        onData(_data);
        update();
      },
      onError: (error) {
        _hasError = true;
        _error = error;
        _data = null;
        onError(error);
        update();
      },
    );

    onSubscribed();
    changeSource = false;
  }

  /// Called before the notifyListeners is called when data has been set
  void onData(T data) {}

  /// Called when the stream is listened too
  void onSubscribed() {}

  /// Called when an error is fired in the stream
  // ignore: type_annotate_public_apis
  void onError(error) {}

  // ignore: public_member_api_docs
  void onCancel() {}

  /// Called before the data is set for the viewmodel
  T transformData(T data) {
    return data;
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
    onCancel();

    super.onClose();
  }

  @override
  void onInit() {
    initialise();
    super.onInit();
  }
}

// ignore: public_member_api_docs
class StreamData<T> extends _SingleDataSourceGetController<T> {
  // ignore: public_member_api_docs
  Stream<T> stream;

  /// Called when the new data arrives
  ///
  /// notifyListeners is called before this so no need to call in here unless
  /// you're running additional logic and setting a separate value.
  Function onData;

  /// Called after the stream has been listened too
  Function onSubscribed;

  /// Called when an error is placed on the stream
  Function onError;

  /// Called when the stream is cancelled
  Function onCancel;

  /// Allows you to modify the data before it's set as the new data for
  /// the model
  ///
  /// This can be used to modify the data if required. If nothing is returned
  /// the data won't be set.
  Function transformData;
  // ignore: public_member_api_docs
  StreamData(
    this.stream, {
    this.onData,
    this.onSubscribed,
    this.onError,
    this.onCancel,
    this.transformData,
  });
  StreamSubscription _streamSubscription;

  // ignore: public_member_api_docs
  void initialise() {
    _streamSubscription = stream.listen(
      (incomingData) {
        _hasError = false;
        _error = null;
        update();
        // Extra security in case transformData isnt sent
        var interceptedData =
            transformData == null ? incomingData : transformData(incomingData);

        if (interceptedData != null) {
          _data = interceptedData;
        } else {
          _data = incomingData;
        }

        update();
        onData(_data);
      },
      onError: (error) {
        _hasError = true;
        _data = null;
        onError(error);
        update();
      },
    );

    onSubscribed();
  }

  @override
  void onClose() {
    _streamSubscription.cancel();
    onCancel();

    super.onClose();
  }
}
