import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:vending_machine/controller/product_controller.dart';
import 'package:vending_machine/model/product_model.dart';
import 'package:vending_machine/model/product_store_model.dart';

void main() {
  // There are three products: cola for $1.00, chips for $0.50, and candy for
  // $0.65.

  test('ProductStore reports accurate store initially', () {
    ProductController productStoreController = new ProductController([
      ProductStoreModel(Candy(), 7),
      ProductStoreModel(Cola(), 5),
      ProductStoreModel(Chips(), 3)
    ]);

    productStoreController.productStoreListStream
        .listen(expectAsync1((List<ProductStoreModel> productStore) {
      expect(productStore.length, 3);
      expect(productStore.first.product.name, Candy().name);
      expect(productStore.first.store, 7);
      expect(productStore.last.product.name, Chips().name);
      expect(productStore.last.store, 3);
    }));
  }, timeout: Timeout(Duration(seconds: 2)));

  test('ProductStore reports accurate store after candy is removed', () async {
    StreamController<Product> productStreamController =
        new StreamController<Product>();
    ProductController productStoreController = new ProductController([
      ProductStoreModel(Candy(), 7),
      ProductStoreModel(Cola(), 5),
      ProductStoreModel(Chips(), 3)
    ], productStreamController: productStreamController);

    int counter = 0;
    productStoreController.productStoreListStream.listen(
        expectAsync2((List<ProductStoreModel> productStore, [dynamic next]) {
      if (counter != 0) {
        expect(productStore.first.product.name, Candy().name);
        expect(productStore.first.store, 6);
      }
      counter++;
    }, count: 2, max: 2));

    productStreamController.add(Candy());
    await Future.delayed(Duration(milliseconds: 300));

    productStreamController.close();
  }, timeout: Timeout(Duration(seconds: 2)));

  test('ProductStore reports accurate store after chips are removed', () async {
    StreamController<Product> productStreamController =
        new StreamController<Product>();
    ProductController productStoreController = new ProductController([
      ProductStoreModel(Candy(), 7),
      ProductStoreModel(Cola(), 5),
      ProductStoreModel(Chips(), 3)
    ], productStreamController: productStreamController);

    int counter = 0;
    productStoreController.productStoreListStream.listen(
        expectAsync2((List<ProductStoreModel> productStore, [dynamic next]) {
      if (counter != 0) {
        expect(productStore.last.product.name, Chips().name);
        expect(productStore.last.store, 2);
      }
      counter++;
    }, count: 2, max: 2));

    productStreamController.add(Chips());
    await Future.delayed(Duration(milliseconds: 300));

    productStreamController.close();
  }, timeout: Timeout(Duration(seconds: 2)));
}
