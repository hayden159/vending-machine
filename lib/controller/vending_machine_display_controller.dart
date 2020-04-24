import 'dart:async';

import 'package:vending_machine/strings.dart';

// CoinReturnController is a fairly simple class that outputs what it is given,
// but maintains a state that it can broadcast at any given time
class VendingMachineDisplayController {
  String _currentDisplay;

  StreamController<String> displayStreamInputController;
  StreamController<String> _displayStreamOutputController;
  Stream<String> displayOutputStream;

  // use displayStreamInputControllerMock to test when
  // VendingMachineDisplayController is not hooked up to a VendingMachineController
  VendingMachineDisplayController(
      {displayStreamInputControllerMock, String initialDisplay}) {
    _currentDisplay = initialDisplay ?? Strings().insertCoin;
    displayStreamInputController =
        displayStreamInputControllerMock ?? new StreamController<String>();
    displayStreamInputController.stream.listen((String string) {
      _currentDisplay = string;
      _displayStreamOutputController.add(_currentDisplay);
    });
    _displayStreamOutputController = new StreamController.broadcast(
        onListen: () => _displayStreamOutputController.add(_currentDisplay));
    displayOutputStream = _displayStreamOutputController.stream;
  }

  dispose() {
    displayStreamInputController.close();
  }
}
