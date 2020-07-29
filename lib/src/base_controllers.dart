import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Contains ViewModel functionality for busy state management
class BaseGetController extends GetxController {
  Map<int, bool> _busyStates = Map<int, bool>();
  Map<int, dynamic> _errorStates = Map<int, dynamic>();

  bool _initialised = false;
  bool get initialised => _initialised;

  bool _onModelReadyCalled = false;
  bool get onModelReadyCalled => _onModelReadyCalled;

  bool _disposed = false;
  bool get disposed => _disposed;

  /// Returns the busy status for an object if it exists. Returns false if not present
  bool busy(Object object) => _busyStates[object.hashCode] ?? false;

  dynamic error(Object object) => _errorStates[object.hashCode];

  /// Returns the busy status of the ViewModel
  bool get isBusy => busy(this);

  /// Returns the error status of the ViewModel
  bool get hasError => error(this) != null;

  /// Returns the error status of the ViewModel
  dynamic get modelError => error(this);

  // Returns true if any objects still have a busy status that is true.
  bool get anyObjectsBusy => _busyStates.values.any((busy) => busy);

  /// Marks the viewmodel as busy and calls notify listeners
  void setBusy(bool value) {
    setBusyForObject(this, value);
  }

  /// Sets the error for the ViewModel
  void setError(dynamic error) {
    setErrorForObject(this, error);
  }

  /// Returns a boolean that indicates if the viewmodel has an error for the key
  bool hasErrorForKey(Object key) => error(key) != null;

  /// Clears all the errors
  void clearErrors() {
    _errorStates.clear();
  }

  /// Sets the busy state for the object equal to the value passed in and notifies Listeners
  /// If you're using a primitive type the value SHOULD NOT BE CHANGED, since Hashcode uses == value
  void setBusyForObject(Object object, bool value) {
    _busyStates[object.hashCode] = value;
    update();
  }

  /// Sets the error state for the object equal to the value passed in and notifies Listeners
  /// If you're using a primitive type the value SHOULD NOT BE CHANGED, since Hashcode uses == value
  void setErrorForObject(Object object, dynamic value) {
    _errorStates[object.hashCode] = value;
    update();
  }

  /// Function that is called when a future throws an error
  void onFutureError(dynamic error, Object key) {}

  /// Sets the ViewModel to busy, runs the future and then sets it to not busy when complete.
  ///
  /// rethrows [Exception] after setting busy to false for object or class
  Future runBusyFuture(Future busyFuture,
      {Object busyObject, bool throwException = false}) async {
    _setBusyForModelOrObject(true, busyObject: busyObject);
    try {
      var value = await runErrorFuture(busyFuture,
          key: busyObject, throwException: throwException);
      _setBusyForModelOrObject(false, busyObject: busyObject);
      return value;
    } catch (e) {
      _setBusyForModelOrObject(false, busyObject: busyObject);
      if (throwException) rethrow;
    }
  }

  Future runErrorFuture(Future future,
      {Object key, bool throwException = false}) async {
    try {
      return await future;
    } catch (e) {
      _setErrorForModelOrObject(e, key: key);
      onFutureError(e, key);
      if (throwException) rethrow;
      return Future.value();
    }
  }

  /// Sets the initialised value for the model to true. This is called after
  /// the first initialise special viewModel call
  void setInitialised(bool value) {
    _initialised = value;
  }

  /// Sets the onModelReadyCalled value to true. This is called after this first onModelReady call
  void setOnModelReadyCalled(bool value) {
    _onModelReadyCalled = value;
  }

  void _setBusyForModelOrObject(bool value, {Object busyObject}) {
    if (busyObject != null) {
      setBusyForObject(busyObject, value);
    } else {
      setBusyForObject(this, value);
    }
  }

  void _setErrorForModelOrObject(dynamic value, {Object key}) {
    if (key != null) {
      setErrorForObject(key, value);
    } else {
      setErrorForObject(this, value);
    }
  }

  // Sets up streamData property to hold data, busy, and lifecycle events
  @protected
  StreamData setupStream<T>(
    Stream<T> stream, {
    onData,
    onSubscribed,
    onError,
    onCancel,
    transformData,
  }) {
    StreamData<T> streamData = StreamData<T>(
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
  void onInit() {
    super.onInit();
    _handleStartupTasks();
  }

  void _handleStartupTasks() {
    if (!onModelReadyCalled) {
      setOnModelReadyCalled(true);
    }
    _initialiseSpecialControllers();
  }

  void _initialiseSpecialControllers() {
    if (this is Initialisable) {
      if (!this.initialised) {
        var controller = this as Initialisable;
        controller.initialise();
      }
    }
  }

  @override
  void onReady() {
    super.onReady();
    if (this is DynamicSourceGetController) {
      var controller = this as DynamicSourceGetController;
      if (controller.changeSource ?? false) {
        _initialiseSpecialControllers();
      }
    }
  }

  @override
  void onClose() {
    _disposed = true;
    super.onClose();
  }
}

@protected
class DynamicSourceGetController<T> extends BaseGetController {
  bool changeSource = false;
  void notifySourceChanged({bool clearOldData = false}) {
    changeSource = true;
  }
}

class _SingleDataSourceGetController<T> extends DynamicSourceGetController {
  T _data;
  T get data => _data;

  dynamic _error;

  @override
  dynamic error([Object object]) => _error;

  bool get dataReady => _data != null && !hasError;
}

class _MultiDataSourceGetController extends DynamicSourceGetController {
  Map<String, dynamic> _dataMap;
  Map<String, dynamic> get dataMap => _dataMap;

  bool dataReady(String key) => _dataMap[key] != null && (error(key) == null);
}

/// Provides functionality for a ViewModel that's sole purpose it is to fetch data using a [Future]
abstract class FutureGetController<T> extends _SingleDataSourceGetController<T>
    implements Initialisable {
  /// The future that fetches the data and sets the view to busy
  @Deprecated('Use the futureToRun function')
  Future<T> get future => null;

  Future<T> futureToRun();

  Future initialise() async {
    setError(null);
    _error = null;
    // We set busy manually as well because when notify listeners is called to clear error messages the
    // ui is rebuilt and if you expect busy to be true it's not.
    setBusy(true);
    update();

    _data = await runBusyFuture(futureToRun(), throwException: true)
        .catchError((error) {
      setError(error);
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
}

/// Provides functionality for a ViewModel to run and fetch data using multiple future
abstract class MultipleFutureGetController extends _MultiDataSourceGetController
    implements Initialisable {
  Map<String, Future Function()> get futuresMap;

  Completer _futuresCompleter;
  int _futuresCompleted;

  void _initialiseData() {
    if (_dataMap == null) {
      _dataMap = Map<String, dynamic>();
    }

    _futuresCompleted = 0;
  }

  Future initialise() {
    _futuresCompleter = Completer();
    _initialiseData();
    // We set busy manually as well because when notify listeners is called to clear error messages the
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
        setErrorForObject(key, error);
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

  void onError({String key, error}) {}

  void onData(String key) {}
}

/// Provides functionality for a ViewModel to run and fetch data using multiple streams
abstract class MultipleStreamGetController extends _MultiDataSourceGetController
    implements Initialisable {
  // Every MultipleStreamViewModel must override streamDataMap
  // StreamData requires a stream, but lifecycle events are optional
  // if a lifecyle event isn't defined we use the default ones here
  Map<String, StreamData> get streamsMap;

  Map<String, StreamSubscription> _streamsSubscriptions;

  @visibleForTesting
  Map<String, StreamSubscription> get streamsSubscriptions =>
      _streamsSubscriptions;

  /// Returns the stream subscription associated with the key
  StreamSubscription getSubscriptionForKey(String key) =>
      _streamsSubscriptions[key];

  void initialise() {
    _dataMap = Map<String, dynamic>();
    clearErrors();
    _streamsSubscriptions = Map<String, StreamSubscription>();

    if (!changeSource) {
      update();
    }

    for (var key in streamsMap.keys) {
      // If a lifecycle function isn't supplied, we fallback to default
      _streamsSubscriptions[key] = streamsMap[key].stream.listen(
        (incomingData) {
          setErrorForObject(key, null);
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
          setErrorForObject(key, error);
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
      clearErrors();
    }

    update();
  }

  void onData(String key, dynamic data) {}
  void onSubscribed(String key) {}
  void onError(String key, error) {}
  void onCancel(String key) {}
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
        onCancel(key);
      }

      _streamsSubscriptions.clear();
    }
  }
}

abstract class StreamGetController<T> extends _SingleDataSourceGetController<T>
    implements DynamicSourceGetController, Initialisable {
  /// Stream to listen to
  Stream<T> get stream;

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
        setError(null);
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
        setError(error);
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
  void onError(error) {}

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
}

class StreamData<T> extends _SingleDataSourceGetController<T> {
  Stream<T> stream;

  /// Called when the new data arrives
  ///
  /// notifyListeners is called before this so no need to call in here unless you're
  /// running additional logic and setting a separate value.
  Function onData;

  /// Called after the stream has been listened too
  Function onSubscribed;

  /// Called when an error is placed on the stream
  Function onError;

  /// Called when the stream is cancelled
  Function onCancel;

  /// Allows you to modify the data before it's set as the new data for the model
  ///
  /// This can be used to modify the data if required. If nothhing is returned the data
  /// won't be set.
  Function transformData;
  StreamData(
    this.stream, {
    this.onData,
    this.onSubscribed,
    this.onError,
    this.onCancel,
    this.transformData,
  });
  StreamSubscription _streamSubscription;

  void initialise() {
    _streamSubscription = stream.listen(
      (incomingData) {
        setError(null);
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
        setError(error);
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

/// Interface: Additional actions that should be implemented by spcialised ViewModels
abstract class Initialisable {
  void initialise();
}
