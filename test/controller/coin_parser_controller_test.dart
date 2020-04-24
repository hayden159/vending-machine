import 'dart:async';
import 'package:flutter_test/flutter_test.dart';
import 'package:vending_machine/controller/coin_parser_controller.dart';
import 'package:vending_machine/model/coin_model.dart';

void main() {

  // The vending machine will accept valid coins (nickels, dimes, and quarters)
  test('Coin parser parses nickel at start range', () {
    double validNickelDiameter = NickelModel().diameterStartRange;
    StreamController<double> mockCoinInputController =
        new StreamController<double>();

    CoinParserController coinParserController =
        new CoinParserController(coinInputStreamController: mockCoinInputController);

    coinParserController.coinOutputStream.listen(expectAsync1((CoinModel coinModel) {
      expect(coinModel.runtimeType, NickelModel);
    }));
    coinParserController.coinParseErrorStream.listen((bool error){
      fail("Nickel should have been parsed");
    });

    mockCoinInputController.add(validNickelDiameter);
    mockCoinInputController.close();
  });

  test('Coin parser parses quarter at end range', () {
    double validQuarterDiameter = QuarterModel().diameterEndRange;
    StreamController<double> mockCoinInputController =
    new StreamController<double>();

    CoinParserController coinParserController =
    new CoinParserController(coinInputStreamController: mockCoinInputController);

    coinParserController.coinOutputStream.listen(expectAsync1((CoinModel coinModel) {
      expect(coinModel.runtimeType, QuarterModel);
    }));
    coinParserController.coinParseErrorStream.listen((bool error){
      fail("Quarter should have been parsed");
    });

    mockCoinInputController.add(validQuarterDiameter);
    mockCoinInputController.close();
  });

  test('Coin parser parses dime at middle range', () {
    double validDimeDiameter = DimeModel().diameterStartRange+.01;
    StreamController<double> mockCoinInputController =
    new StreamController<double>();

    CoinParserController coinParserController =
    new CoinParserController(coinInputStreamController: mockCoinInputController);

    coinParserController.coinOutputStream.listen(expectAsync1((CoinModel coinModel) {
      expect(coinModel.runtimeType, DimeModel);
    }));
    coinParserController.coinParseErrorStream.listen((bool error){
      fail("Dime should have been parsed");
    });

    mockCoinInputController.add(validDimeDiameter);
    mockCoinInputController.close();
  });

  // and reject invalid ones (pennies).
  test('Coin parser valid pennies rejected', () {
    double validPennyDiameter = PennyModel().diameterStartRange;
    StreamController<double> mockCoinInputController =
    new StreamController<double>();

    CoinParserController coinParserController =
    new CoinParserController(coinInputStreamController: mockCoinInputController);

    coinParserController.coinParseErrorStream.listen(expectAsync1((bool error) {
      expect(error, isTrue);
    }));
    coinParserController.coinOutputStream.listen((CoinModel coinModel){
      fail("Penny should not have been parsed");
    });

    mockCoinInputController.add(validPennyDiameter);
    mockCoinInputController.close();
  });

  test('Coin parser rejects coins that can not be parsed', () {
    double invalidDiameter = .05;
    StreamController<double> mockCoinInputController =
    new StreamController<double>();

    CoinParserController coinParserController =
    new CoinParserController(coinInputStreamController: mockCoinInputController);

    coinParserController.coinParseErrorStream.listen(expectAsync1((bool error) {
      expect(error, isTrue);
    }));
    coinParserController.coinOutputStream.listen((CoinModel coinModel){
      fail("invalid coin should not have been parsed");
    });

    mockCoinInputController.add(invalidDiameter);
    mockCoinInputController.close();
  });
}
