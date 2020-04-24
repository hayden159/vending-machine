import 'dart:async';

import 'package:vending_machine/model/coin_model.dart';


// CoinParserController accepts coin diameters through a 'coin slot'
// and parse them into coin models.
class CoinParserController {
  // input stream controllers (user coin input)
  StreamController<double> _coinInputStreamController;

  // output streams
  StreamController<CoinModel> _coinOutputStreamController;
  StreamController<bool> _coinParseErrorStreamController;
  Stream<CoinModel> coinOutputStream;
  Stream<bool> coinParseErrorStream;

  CoinParserController({coinInputStreamController}) {
    _coinInputStreamController =
        coinInputStreamController ?? StreamController<double>();
    _coinInputStreamController.stream.listen(_consumeCoin);

    _coinOutputStreamController = new StreamController<CoinModel>();
    _coinParseErrorStreamController = new StreamController<bool>();

    coinOutputStream = _coinOutputStreamController.stream;
    coinParseErrorStream = _coinParseErrorStreamController.stream;
  }

  void _consumeCoin(double newCoinDiameter) {
    //parse coin
    CoinModel coin = _diameterToCoinModel(newCoinDiameter);
    if (coin == null) {
      _spitCoinOut();
      return;
    }

    //validate coin is a type which the machine accepts
    bool valid = _validateCoinType(coin);
    if (!valid) {
      _spitCoinOut();
      return;
    }

    //add coin to stash
    _coinOutputStreamController.add(coin);
  }

  // returns null if coin could not be parsed
  CoinModel _diameterToCoinModel(double diameter) {
    CoinModel matchingCoinModel = [
      PennyModel(),
      NickelModel(),
      DimeModel(),
      QuarterModel()
    ].firstWhere((CoinModel model) {
      return diameter <= model.diameterEndRange &&
          diameter >= model.diameterStartRange;
    }, orElse: () => null);
    return matchingCoinModel;
  }

  bool _validateCoinType(CoinModel coin) {
    // the machine denies pennies
    if (coin.runtimeType == PennyModel)
      return false;
    else
      return true;
  }

  void _spitCoinOut() {
    _coinParseErrorStreamController.add(true);
  }

  void dispose() {
    _coinOutputStreamController.close();
    _coinParseErrorStreamController.close();
    _coinInputStreamController.close();
  }
}
