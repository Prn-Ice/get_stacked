import 'dart:math';

import 'package:get_stacked/get_stacked.dart';

class TestViewModel extends MultipleFutureGetController {
  static const String _stringKey = 'strings';
  static const String _intKey = 'ints';

  bool get fetchingString => busy(_stringKey);
  bool get fetchingInt => busy(_intKey);

  int get fetchedNumber => dataMap[_intKey];
  String get fetchedString => dataMap[_stringKey];

  @override
  Map<String, Future Function()> get futuresMap => {
        _stringKey: _fetchString,
        _intKey: _fetchInt,
      };

  Future<int> _fetchInt() async {
    await Future.delayed(Duration(seconds: 2));
    return Random().nextInt(10);
  }

  Future<String> _fetchString() async {
    await Future.delayed(Duration(seconds: 4));
    return 'Done';
  }
}
