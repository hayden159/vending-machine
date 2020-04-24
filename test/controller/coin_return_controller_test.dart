import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vending_machine/controller/coin_return_controller.dart';

void main() {
  test('Coin return outputs coins it is given', () {
    StreamController<String> coinInputController =
        new StreamController<String>();
    CoinReturnController coinReturnController = new CoinReturnController(
        coinReturnInputControllerMock: coinInputController);

    coinReturnController.coinReturnOutputStream
        .listen(expectAsync1((String coin) {
      expect(coin, isNotNull);
      expect(coin, ".25");
    }));

    coinInputController.add(".25");

    coinInputController.close();
  }, timeout: Timeout(Duration(seconds: 2)));
}
