import 'package:vending_machine/model/coin_model.dart';
import 'package:vending_machine/model/coin_store_model.dart';
import 'package:vending_machine/model/product_model.dart';
import 'package:vending_machine/model/product_store_model.dart';

List<ProductStoreModel> genericProductStoreModel = [
  ProductStoreModel(Candy(), 3),
  ProductStoreModel(Cola(), 2),
  ProductStoreModel(Chips(), 4)
];

List<ProductStoreModel> chipsSoldOutProductStoreModel = [
  ProductStoreModel(Candy(), 3),
  ProductStoreModel(Cola(), 2),
  ProductStoreModel(Chips(), 0)
];

List<CoinStoreModel> genericCoinStoreModel = [
  CoinStoreModel(QuarterModel(), 8),
  CoinStoreModel(NickelModel(), 7),
  CoinStoreModel(DimeModel(), 9)
];

List<CoinStoreModel> noNickelsCoinStoreModel = [
  CoinStoreModel(QuarterModel(), 4),
  CoinStoreModel(NickelModel(), 0),
  CoinStoreModel(DimeModel(), 9)
];