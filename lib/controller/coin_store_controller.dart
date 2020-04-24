import 'dart:async';

import 'package:vending_machine/model/coin_model.dart';
import 'package:vending_machine/model/coin_store_model.dart';

class CoinStoreController {
  List<CoinStoreModel> _coinStore;

  // input stream controllers
  StreamController<CoinModel> _coinModelInputStream;

  // output streams
  StreamController<List<CoinStoreModel>> _coinStoreOutputController;
  Stream<List<CoinStoreModel>> coinStoreOutputStream;

  CoinStoreController(List<CoinStoreModel> coinStore,
      {StreamController<CoinModel> coinStreamController}) {
    _coinStore = coinStore;
    _coinModelInputStream =
        coinStreamController ?? new StreamController<CoinModel>();
    coinStreamController.stream.listen(_handleNewCoin);
    _coinStoreOutputController = new StreamController(
        onListen: () => _coinStoreOutputController.add(_coinStore));
    coinStoreOutputStream = _coinStoreOutputController.stream;
  }

  void _handleNewCoin(CoinModel coin) {
    CoinStoreModel coinStoreModel = _coinStore.firstWhere(
        (CoinStoreModel storeModel) => storeModel.coinModel.name == coin.name);
    coinStoreModel.store++;
    _coinStoreOutputController.add(_coinStore);
  }

  dispose() {
    _coinModelInputStream.close();
  }
}
