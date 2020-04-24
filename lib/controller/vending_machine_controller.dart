import 'dart:async';

import 'package:vending_machine/controller/coin_return_controller.dart';
import 'package:vending_machine/controller/coin_store_controller.dart';
import 'package:vending_machine/controller/product_controller.dart';
import 'package:vending_machine/controller/coin_parser_controller.dart';
import 'package:vending_machine/controller/vending_machine_display_controller.dart';
import 'package:vending_machine/model/coin_store_model.dart';
import 'package:vending_machine/model/vending_machine_store_model.dart';
import 'package:vending_machine/strings.dart';
import 'package:vending_machine/model/coin_model.dart';
import 'package:vending_machine/model/product_model.dart';
import 'package:vending_machine/model/product_store_model.dart';

// VendingMachineController is the main brain of the application.
// if this application became a production mobile application,
// most of the logic in VendingMachineController would be moved to
// a backend server. VendingMachineController maintains application state
// and facilitates interactions from different components. It also
// provides helper functions that the UI would use.

class VendingMachineController {
  // _vendingMachineModel acts as a data store for the vending machine instance
  VendingMachineStore _vendingMachineStore;

  // CoinParser component references
  CoinParserController _coinParserController;
  StreamController<double> _coinInputStreamController;

  // Vending Machine Display references
  VendingMachineDisplayController _vendingMachineController;
  StreamController<String> _displayInputStreamController;

  // Coin Return references
  CoinReturnController _coinReturnController;
  StreamController<String> _coinReturnInputController;

  // Product references
  ProductController _productController;
  StreamController<Product> _productStreamController;

  // Coin Store references
  CoinStoreController _coinStoreController;
  StreamController<CoinModel> _coinAddedStreamController;

  // Constructor
  VendingMachineController(List<ProductStoreModel> productStoreModel,
      List<CoinStoreModel> coinStoreModel,
      {CoinParserController coinParserController,
      VendingMachineDisplayController vendingMachineDisplayController,
      ProductController productController,
      CoinReturnController coinReturnController,
      CoinStoreController coinStoreController}) {
    _vendingMachineStore = new VendingMachineStore();
    _vendingMachineStore.coinStoreModel = coinStoreModel;
    _vendingMachineStore.productStoreModel = productStoreModel;

    // CoinParser component references
    _coinInputStreamController = new StreamController<double>();
    _coinParserController = coinParserController ??
        CoinParserController(
            coinInputStreamController: _coinInputStreamController);
    _coinParserController.coinOutputStream.listen(_handleCoinInserted);
    _coinParserController.coinParseErrorStream.listen(_handleCoinParseError);

    // Vending Machine Display references
    _vendingMachineController = vendingMachineDisplayController ??
        VendingMachineDisplayController(
            initialDisplay: _getInitialVendingMachineMessage());
    _displayInputStreamController =
        _vendingMachineController.displayStreamInputController;

    // Coin Return references
    _coinReturnController = coinReturnController ?? new CoinReturnController();
    _coinReturnInputController =
        _coinReturnController.coinReturnInputController;

    // Product references
    _productStreamController = new StreamController<Product>();
    _productController = productController ??
        new ProductController(productStoreModel,
            productStreamController: _productStreamController);
    _productController.productStoreListStream.listen(_updateProductStore);

    // Coin Store references
    _coinAddedStreamController = new StreamController<CoinModel>();
    _coinStoreController = coinStoreController ??
        new CoinStoreController(coinStoreModel,
            coinStreamController: _coinAddedStreamController);
    _coinStoreController.coinStoreOutputStream.listen(_updateCoinStore);
  } // End Constructor

  // Helper functions that the UI would call
  void addQuarter() {
    _coinInputStreamController.add(QuarterModel().diameterStartRange);
  }

  void addPenny() {
    _coinInputStreamController.add(PennyModel().diameterStartRange);
  }

  void addDime() {
    _coinInputStreamController.add(DimeModel().diameterStartRange);
  }

  void addNickel() {
    _coinInputStreamController.add(NickelModel().diameterStartRange);
  }

  void selectChips() {
    _validateSelectionAndDispense(Chips());
  }

  void selectCandy() {
    _validateSelectionAndDispense(Candy());
  }

  void selectCola() {
    _validateSelectionAndDispense(Cola());
  }

  void pressCoinReturn() {
    _returnCoinsAndReset();
  }
  // end Helper Functions


  void _returnCoinsAndReset() {
    if (_vendingMachineStore.amountInserted > 0.0) {
      _coinReturnInputController
          .add(_vendingMachineStore.amountInserted.toString());
      _vendingMachineStore.amountInserted = 0.0;
    }
    _displayInputStreamController.add(_getInitialVendingMachineMessage());
  }

  void _handleCoinInserted(CoinModel coinModel) {
    _coinAddedStreamController.add(coinModel);
    _vendingMachineStore.amountInserted =
        _vendingMachineStore.amountInserted + coinModel.amount;
    _displayCurrentAmount();
  }

  void _handleCoinParseError(bool event) {
    _coinReturnInputController.add("invalid coin");
  }

  void _displayCurrentAmount() {
    _displayInputStreamController
        .add(_vendingMachineStore.amountInserted.toString());
  }

  bool _validateFunds(Product product) {
    if (_vendingMachineStore.amountInserted >= product.price)
      return true;
    else
      return false;
  }

  bool _validateStore(Product product) {
    ProductStoreModel productStore = _vendingMachineStore.productStoreModel
        .firstWhere((ProductStoreModel productStore) =>
            productStore.product.name == product.name);
    return productStore.store >= 1;
  }

  void _updateProductStore(List<ProductStoreModel> store) {
    _vendingMachineStore.productStoreModel = store;
  }

  void _updateCoinStore(List<CoinStoreModel> store) {
    _vendingMachineStore.coinStoreModel = store;
  }

  Future<void> _validateSelectionAndDispense(Product product) async {
    bool hasFunds = _validateFunds(product);
    if (!hasFunds) {
      _displayInputStreamController
          .add(Strings().price + " " + product.price.toString());
      return;
    }

    bool hasStore = _validateStore(product);
    if (!hasStore) {
      _displayInputStreamController.add(Strings().soldOut);
      await Future.delayed(Duration(milliseconds: 200));
      _displayCurrentAmount();
      return;
    }
    _productStreamController.add(product);
    _displayInputStreamController.add(Strings().thankYou);
    _vendingMachineStore.amountInserted = double.parse(
        (_vendingMachineStore.amountInserted - product.price)
            .toStringAsFixed(2));
    _vendProductAndReset();
  }

  String _getInitialVendingMachineMessage() {
    bool outOfAnyCoins = _vendingMachineStore.coinStoreModel
        .any((CoinStoreModel coinStoreModel) {
      return coinStoreModel.store < 1;
    });
    if (outOfAnyCoins) {
      return Strings().exactChangeOnly;
    } else {
      return Strings().insertCoin;
    }
  }

  dispose() {
    _coinInputStreamController.close();
    _displayInputStreamController.close();
  }

  void _vendProductAndReset() async {
    await Future.delayed(Duration(milliseconds: 200));
    _returnCoinsAndReset();
  }
}
