import 'dart:async';

// CoinReturnController is a really simple class that outputs what it is given.
// it would have more use if it were hooked up to a UI element.
class CoinReturnController {

  StreamController<String> coinReturnInputController;
  StreamController<String> _coinReturnOutputController;
  Stream<String> coinReturnOutputStream;

  // use coinReturnInputControllerMock to test when
  // CoinReturnController is not hooked up to a VendingMachineController
  CoinReturnController({coinReturnInputControllerMock}) {
    coinReturnInputController =
        coinReturnInputControllerMock ?? new StreamController<String>();
    _coinReturnOutputController = new StreamController<String>();
    coinReturnInputController.stream.listen((String amount) {
      _coinReturnOutputController.add(amount);
    });
    coinReturnOutputStream = _coinReturnOutputController.stream;
  }

  dispose() {
    coinReturnInputController.close();
  }
}
