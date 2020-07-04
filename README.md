# GetStacked

This package is an implementation of the [Stacked](https://pub.dev/packages/stacked) package using [Get](https://pub.dev/packages/get).

For those unfamiliar with the Stacked architecture I strongly advice that you head over to the documentation for the for the [stacked](https://pub.dev/packages/stacked) package and also check out some of the tutorials [here](https://www.filledstacks.com/).

If you are familiar with the stacked architecture, this is a version of the [Stacked](https://pub.dev/packages/stacked) package based around [Get](https://pub.dev/packages/get) for state management, whereas the stacked package originally used [provider](https://pub.dev/packages/provider).

## Coming From [Stacked](https://pub.dev/packages/stacked)

### The BaseViewModel

The `BaseViewModel` equivalent in this package is the `BaseGetController`.
I'll use an example from the stacked package's documentation to show the similarities and differences.

#### Stacked

**Model:**

```dart
class WidgetOneViewModel extends BaseViewModel {

  Human _currentHuman;
  Human get currentHuman => _currentHuman;

  void setBusyOnProperty() {
    setBusyForObject(_currentHuman, true);
    // Fetch updated human data
    setBusyForObject(_currentHuman, false);
  }

  void setModelBusy() {
    setBusy(true);
    // Do things here
    setBusy(false);
  }

  Future longUpdateStuff() async {
    // Sets busy to true before starting future and sets it to false after executing
    // You can also pass in an object as the busy object. Otherwise it'll use the model
    var result = await runBusyFuture(updateStuff());
  }

  Future updateStuff() {
    return Future.delayed(const Duration(seconds: 3));
  }
}
```

**View:**

```dart
class WidgetOne extends StatelessWidget {
  const WidgetOne({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ViewModelBuilder<WidgetOneViewModel>.reactive(
      viewModelBuilder: () => WidgetOneViewModel(),
      builder: (context, model, child) => GestureDetector(
        onTap: () => model.longUpdateStuff(),
        child: Container(
          width: 100,
          height: 100,
          // Use isBusy to check if the model is set to busy
          color: model.isBusy ? Colors.green : Colors.red,
          alignment: Alignment.center,
          // A bit silly to pass the same property back into the viewmodel
          // but here it makes sense
          child: model.busy(model.currentHuman)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(/* Human Details styling */)
        ),
      ),
    );
  }
}
```

#### With GetStacked

**Controller:**

```dart
class WidgetOneViewModel extends BaseGetController {

  Human _currentHuman;
  Human get currentHuman => _currentHuman;

  void setBusyOnProperty() {
    setBusyForObject(_currentHuman, true);
    // Fetch updated human data
    setBusyForObject(_currentHuman, false);
  }

  void setModelBusy() {
    setBusy(true);
    // Do things here
    setBusy(false);
  }

  Future longUpdateStuff() async {
    // Sets busy to true before starting future and sets it to false after executing
    // You can also pass in an object as the busy object. Otherwise it'll use the model
    var result = await runBusyFuture(updateStuff());
  }

  Future updateStuff() {
    return Future.delayed(const Duration(seconds: 3));
  }
}
```

**View:**

```dart
class WidgetOne extends StatelessWidget {
  const WidgetOne({Key key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetBuilder(
      init: WidgetOneViewModel(),
      builder: (model) => GestureDetector(
        onTap: () => model.longUpdateStuff(),
        child: Container(
          width: 100,
          height: 100,
          // Use isBusy to check if the model is set to busy
          color: model.isBusy ? Colors.green : Colors.red,
          alignment: Alignment.center,
          // A bit silly to pass the same property back into the viewmodel
          // but here it makes sense
          child: model.busy(model.currentHuman)
              ? Center(
                  child: CircularProgressIndicator(),
                )
              : Container(/* Human Details styling */)
        ),
      ),
    );
  }
}
```

Check out the example for more realistic scenarios.

All suggestions, issues, pull requests would be appreciated.
