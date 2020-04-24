import 'dart:async';

// CoinReturnController is a simple class that outputs the string
// it was given. Though it seems unnecessary, it is used for testing
// and would be useful when connected to a UI.
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
