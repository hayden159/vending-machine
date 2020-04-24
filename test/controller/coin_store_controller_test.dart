import 'package:flutter_test/flutter_test.dart';
import 'package:vending_machine/controller/coin_store_controller.dart';
import 'package:vending_machine/model/coin_model.dart';
import 'package:vending_machine/model/coin_store_model.dart';

void main() {

  test('CoinStore reports accurate store initially', () {
    CoinStoreController coinStoreController = new CoinStoreController([
      CoinStoreModel(QuarterModel(), 7),
      CoinStoreModel(DimeModel(), 5),
      CoinStoreModel(NickelModel(), 3)
    ]);

    coinStoreController.coinStoreOutputStream
        .listen(expectAsync1((List<CoinStoreModel> coinStore) {
      expect(coinStore.length, 3);
      expect(coinStore.first.store, 7);
      expect(coinStore.first.coinModel.name, "Quarter");
    }));
  }, timeout: Timeout(Duration(seconds: 2)));

}
