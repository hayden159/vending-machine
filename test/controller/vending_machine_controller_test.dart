import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vending_machine/controller/coin_return_controller.dart';
import 'package:vending_machine/controller/coin_store_controller.dart';
import 'package:vending_machine/controller/vending_machine_controller.dart';
import 'package:vending_machine/controller/vending_machine_display_controller.dart';
import 'package:vending_machine/strings.dart';
import 'package:vending_machine/model/product_model.dart';

import 'mock_store_models.dart';

void main() {
  /// Tests related to User Story 1:
  // As a vendor
  //I want a vending machine that accepts coins
  //So that I can collect money from the customer

  // The vending machine will accept valid coins (nickels, dimes, and quarters)
  // and reject invalid ones (pennies). <-- This is tested in
  // coin_parser_controller_test.dart

  // When a valid coin is inserted the amount of the coin will be added
  // to the current amount and the display will be updated.
  // When there are no coins inserted, the machine displays INSERT COIN.
  // Rejected coins are placed in the coin return.

  test('Machine Displays INSERT COIN when there are no coins', () {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    vendingMachineDisplayController.displayOutputStream
        .listen(expectAsync1((String string) {
      expect(string, Strings().insertCoin);
    }));

    new VendingMachineController(
        genericProductStoreModel, genericCoinStoreModel,
        vendingMachineDisplayController: vendingMachineDisplayController);
  }, timeout: Timeout(Duration(seconds: 2)));

  test('Machine Displays 0.25 when a quarter is added', () {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    int count = 0;
    vendingMachineDisplayController.displayOutputStream
        .listen(expectAsync2((String string, [dynamic next]) {
      if (count == 0) {
        expect(string, Strings().insertCoin);
      } else if (count == 1) {
        expect(string, "0.25");
      }
      count++;
    }, count: 2, max: 2));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController);

    vendingMachineController.addQuarter();
  });

  test('Machine Displays .1 when a dime is added', () {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    int count = 0;
    vendingMachineDisplayController.displayOutputStream
        .listen(expectAsync2((String string, [dynamic next]) {
      if (count == 0) {
        expect(string, Strings().insertCoin);
      } else if (count == 1) {
        expect(string, "0.1");
      }
      count++;
    }, count: 2, max: 2));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController);

    vendingMachineController.addDime();
  });

  test('Machine Displays 0.05 when a nickel is added', () {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    int count = 0;
    vendingMachineDisplayController.displayOutputStream
        .listen(expectAsync2((String string, [dynamic next]) {
      if (count == 0) {
        expect(string, Strings().insertCoin);
      } else if (count == 1) {
        expect(string, "0.05");
      }
      count++;
    }, count: 2, max: 2));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController);

    vendingMachineController.addNickel();
  });

  test('Machine does not display .01 when a penny is added, and rejects coin',
      () {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    vendingMachineDisplayController.displayOutputStream
        .listen(expectAsync1((String string) {
      expect(string, Strings().insertCoin);
    }, max: 1));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController);

    vendingMachineController.addPenny();
  });

  test('Machine adds the amount of two valid coins and displays correct number',
      () async {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    int count = 0;
    vendingMachineDisplayController.displayOutputStream
        .listen(expectAsync3((String string, [dynamic next2, dynamic next3]) {
      if (count == 0) {
        expect(string, Strings().insertCoin);
      } else if (count == 1) {
        expect(string, "0.05");
      } else if (count == 2) {
        expect(string, "0.3");
      }
      count++;
    }, count: 3, max: 3));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController);

    vendingMachineController.addNickel();
    await Future.delayed(Duration(milliseconds: 200));
    vendingMachineController.addQuarter();
  });

  test('Machine adds two valid coins, then rejects an invalid', () async {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    int count = 0;
    vendingMachineDisplayController.displayOutputStream.listen(expectAsync4(
        (String string, [dynamic next2, dynamic next3, dynamic next4]) {
      if (count == 0) {
        expect(string, Strings().insertCoin);
      } else if (count == 1) {
        expect(string, "0.1");
      } else if (count == 2) {
        expect(string, "0.35");
      } else if (count == 3) {
        fail("display should not have reacted to rejected coin");
      }
      count++;
    }, count: 3, max: 4));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController);

    vendingMachineController.addDime();
    await Future.delayed(Duration(milliseconds: 200));
    vendingMachineController.addQuarter();
    await Future.delayed(Duration(milliseconds: 200));
    vendingMachineController.addPenny();
  });

  /// Tests related to User Story 2:
  // Select Product
  // As a vendor
  // I want customers to select products
  // So that I can give them an incentive to put money in the machine
  //
  // There are three products: cola for $1.00, chips for $0.50, and candy for
  // $0.65. When the respective button is pressed and enough money has been
  // inserted, the product is dispensed and the machine displays THANK YOU.
  // If the display is checked again, it will display INSERT COIN and the
  // current amount will be set to $0.00. If there is not enough money inserted
  // then the machine displays PRICE and the price of the item and subsequent
  // checks of the display will display either INSERT COIN or the current amount
  // as appropriate.

  test(
      'Machine displays Price when a product is selected and there is no money',
      () async {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    int count = 0;
    vendingMachineDisplayController.displayOutputStream
        .listen(expectAsync2((String string, [dynamic next]) {
      if (count == 0) {
        expect(string, Strings().insertCoin);
      } else if (count == 1) {
        expect(string, Strings().price + " " + Candy().price.toString());
      }
      count++;
    }, count: 2, max: 2));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController);

    vendingMachineController.selectCandy();
    await Future.delayed(Duration(milliseconds: 200));
  });

  test(
      'Machine displays Price when a product is selected and there is some money',
      () async {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    int count = 0;
    vendingMachineDisplayController.displayOutputStream
        .listen(expectAsync3((String string, [dynamic next1, dynamic next2]) {
      if (count == 0) {
        expect(string, Strings().insertCoin);
      } else if (count == 1) {
        expect(string, "0.1");
      } else if (count == 2) {
        expect(string, Strings().price + " " + Candy().price.toString());
      }
      count++;
    }, count: 3, max: 3));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController);

    vendingMachineController.addDime();
    await Future.delayed(Duration(milliseconds: 200));

    vendingMachineController.selectCandy();
    await Future.delayed(Duration(milliseconds: 200));
  });

  test(
      'Machine vends and displays thank you when there is enough money and store',
      () async {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    int count = 0;
    vendingMachineDisplayController.displayOutputStream.listen(expectAsync4(
        (String string, [dynamic next1, dynamic next2, dynamic next3]) {
      if (count == 0) {
        expect(string, Strings().insertCoin);
      } else if (count == 1) {
        expect(string, "0.25");
      } else if (count == 2) {
        expect(string, "0.5");
      } else if (count == 3) {
        expect(string, Strings().thankYou);
      } else if (count == 4) {
        expect(string, Strings().insertCoin);
      }
      count++;
    }, count: 5, max: 5));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController);

    vendingMachineController.addQuarter();
    await Future.delayed(Duration(milliseconds: 200));
    vendingMachineController.addQuarter();
    await Future.delayed(Duration(milliseconds: 200));

    vendingMachineController.selectChips();
    await Future.delayed(Duration(milliseconds: 200));
  });

  test(
      'Machine vends, then reflects correct price when another coin is inserted',
      () async {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    int count = 0;
    vendingMachineDisplayController.displayOutputStream.listen(expectAsync6(
        (String string,
            [dynamic next1,
            dynamic next2,
            dynamic next3,
            dynamic next4,
            dynamic next5]) {
      if (count == 0) {
        expect(string, Strings().insertCoin);
      } else if (count == 1) {
        expect(string, "0.25");
      } else if (count == 2) {
        expect(string, "0.5");
      } else if (count == 3) {
        expect(string, Strings().thankYou);
      } else if (count == 4) {
        expect(string, Strings().insertCoin);
      } else if (count == 5) {
        expect(string, '0.05');
      }
      count++;
    }, count: 6, max: 6));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController);

    vendingMachineController.addQuarter();
    await Future.delayed(Duration(milliseconds: 200));
    vendingMachineController.addQuarter();
    await Future.delayed(Duration(milliseconds: 200));

    vendingMachineController.selectChips();
    await Future.delayed(Duration(milliseconds: 300));

    vendingMachineController.addNickel();
    await Future.delayed(Duration(milliseconds: 200));
  });

  /// Tests related to user story 3
  // Make Change
  // As a vendor
  // I want customers to receive correct change
  // So that they will use the vending machine again
  //
  // When a product is selected that costs less than the amount of money
  // in the machine, then the remaining amount is placed in the coin return.
  test('Machine vends, then returns change', () async {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    CoinReturnController coinReturnController = new CoinReturnController();

    int count = 0;
    vendingMachineDisplayController.displayOutputStream.listen(expectAsync6(
        (String string,
            [dynamic next1,
            dynamic next2,
            dynamic next3,
            dynamic next4,
            dynamic next5]) {
      if (count == 0) {
        expect(string, Strings().insertCoin);
      } else if (count == 1) {
        expect(string, "0.25");
      } else if (count == 2) {
        expect(string, "0.5");
      } else if (count == 3) {
        expect(string, '0.75');
      } else if (count == 4) {
        expect(string, Strings().thankYou);
      } else if (count == 5) {
        expect(string, Strings().insertCoin);
      }
      count++;
    }, count: 6, max: 6));

    coinReturnController.coinReturnOutputStream
        .listen(expectAsync1((String returned) {
      expect(returned, "0.1");
    }));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            coinReturnController: coinReturnController,
            vendingMachineDisplayController: vendingMachineDisplayController);

    vendingMachineController.addQuarter();
    await Future.delayed(Duration(milliseconds: 200));
    vendingMachineController.addQuarter();
    await Future.delayed(Duration(milliseconds: 200));
    vendingMachineController.addQuarter();
    await Future.delayed(Duration(milliseconds: 200));

    vendingMachineController.selectCandy();
    await Future.delayed(Duration(milliseconds: 300));
  });

  /// Tests related to user story 4
  // Return Coins
  // As a customer
  // I want to have my money returned
  // So that I can change my mind about buying stuff from the vending machine
  //
  // When the return coins button is pressed, the money the customer has
  // placed in the machine is returned and the display shows INSERT COIN.
  test('Machine returns an invalid coin', () async {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();
    CoinReturnController coinReturnController = new CoinReturnController();

    vendingMachineDisplayController.displayOutputStream
        .listen(expectAsync1((String string) {
      expect(string, Strings().insertCoin);
      expect(string, Strings().insertCoin);
    }));

    coinReturnController.coinReturnOutputStream
        .listen(expectAsync1((String returned) {
      expect(returned, "invalid coin");
    }));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController,
            coinReturnController: coinReturnController);

    vendingMachineController.addPenny();
    await Future.delayed(Duration(milliseconds: 200));
  }, timeout: Timeout(Duration(seconds: 3)));

  test('Machine returns a quarter', () async {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();
    CoinReturnController coinReturnController = new CoinReturnController();

    int count = 0;
    vendingMachineDisplayController.displayOutputStream
        .listen(expectAsync3((String string, [dynamic next1, dynamic next2]) {
      if (count == 0) {
        expect(string, Strings().insertCoin);
      } else if (count == 1) {
        expect(string, "0.25");
      } else if (count == 2) {
        expect(string, Strings().insertCoin);
      }
      count++;
    }, count: 3, max: 3));

    coinReturnController.coinReturnOutputStream
        .listen(expectAsync1((String returned) {
      expect(returned, "0.25");
    }));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController,
            coinReturnController: coinReturnController);

    vendingMachineController.addQuarter();
    await Future.delayed(Duration(milliseconds: 200));

    vendingMachineController.pressCoinReturn();
    await Future.delayed(Duration(milliseconds: 200));
  }, timeout: Timeout(Duration(seconds: 3)));

  /// tests related to user story 5
  // Sold Out
  //As a customer
  //I want to be told when the item I have selected is not available
  //So that I can select another item
  //
  // When the item selected by the customer is out of store, the machine displays
  // SOLD OUT. If the display is checked again, it will display the amount of
  // money remaining in the machine or INSERT COIN if there is no money
  // in the machine.
  test(
      'Machine displays sold out when funds are sufficient but the product is out of store',
      () async {
    VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

    int count = 0;
    vendingMachineDisplayController.displayOutputStream.listen(expectAsync5(
        (String string,
            [dynamic next1, dynamic next2, dynamic next3, dynamic next4]) {
      if (count == 0) {
        expect(string, Strings().insertCoin);
      } else if (count == 1) {
        expect(string, "0.25");
      } else if (count == 2) {
        expect(string, "0.5");
      } else if (count == 3) {
        expect(string, Strings().soldOut);
      } else if (count == 4) {
        expect(string, "0.5");
      }
      count++;
    }, count: 5, max: 5));

    VendingMachineController vendingMachineController =
        new VendingMachineController(
            chipsSoldOutProductStoreModel, genericCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController);

    vendingMachineController.addQuarter();
    await Future.delayed(Duration(milliseconds: 200));
    vendingMachineController.addQuarter();
    await Future.delayed(Duration(milliseconds: 200));

    vendingMachineController.selectChips();
    await Future.delayed(Duration(milliseconds: 200));
  });

  /// tests related to user story 6
  // Exact Change Only
  // As a customer
  // I want to be told when exact change is required
  // So that I can determine if I can buy something with the money I have before
  // inserting it
  //
  //When the machine is not able to make change with the money in the machine
  // for any of the items that it sells, it will display EXACT CHANGE ONLY
  // instead of INSERT COIN.
  test(
      'Machine Displays EXACT CHANGE ONLY instead of INSERT COIN when there are not enough coins in the store',
      () async {
        VendingMachineDisplayController vendingMachineDisplayController =
        new VendingMachineDisplayController();

        int count = 0;
        vendingMachineDisplayController.displayOutputStream.listen(expectAsync5(
                (String string,
                [dynamic next1, dynamic next2, dynamic next3, dynamic next4]) {
              if (count == 0) {
                expect(string, Strings().insertCoin);
              } else if (count == 1) {
                expect(string, "0.25");
              } else if (count == 2) {
                expect(string, "0.5");
              } else if (count == 3) {
                expect(string, Strings().thankYou);
              } else if (count == 4) {
                expect(string, Strings().exactChangeOnly);
              }
              count++;
            }, count: 5, max: 5));

        VendingMachineController vendingMachineController =
        new VendingMachineController(
            genericProductStoreModel, noNickelsCoinStoreModel,
            vendingMachineDisplayController: vendingMachineDisplayController);

        vendingMachineController.addQuarter();
        await Future.delayed(Duration(milliseconds: 200));
        vendingMachineController.addQuarter();
        await Future.delayed(Duration(milliseconds: 200));

        vendingMachineController.selectChips();
        await Future.delayed(Duration(milliseconds: 200));
  }, timeout: Timeout(Duration(seconds: 2)));
}
