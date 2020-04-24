import 'dart:async';

import 'package:vending_machine/model/product_model.dart';
import 'package:vending_machine/model/product_store_model.dart';

class ProductController {
  List<ProductStoreModel> _productStore;

  // input stream controllers
  StreamController<Product> _productSelectedStreamController;

  // output streams
  StreamController<List<ProductStoreModel>> _productStoreListController;
  Stream<List<ProductStoreModel>> productStoreListStream;

  ProductController(List<ProductStoreModel> productStore,
      {StreamController<Product> productStreamController}) {
    _productStore = productStore;
    _productSelectedStreamController =
        productStreamController ?? new StreamController<Product>();
    _productSelectedStreamController.stream.listen(_handleSelectedProduct);
    _productStoreListController = new StreamController(
        onListen: () => _productStoreListController.add(_productStore));
    productStoreListStream = _productStoreListController.stream;
  }

  void _handleSelectedProduct(Product product) {
    ProductStoreModel selectedProductStoreModel = _productStore.firstWhere(
        (ProductStoreModel storeModel) => storeModel.product.name == product.name);
    selectedProductStoreModel.store--;
    _productStoreListController.add(_productStore);
  }

  dispose() {
    _productSelectedStreamController.close();
  }
}
