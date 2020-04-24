abstract class CoinModel {
  String get name;
  double get amount;
  double get diameterStartRange;
  double get diameterEndRange;
}

class PennyModel extends CoinModel {
  @override
  String get name => "Penny";

  @override
  double get amount => .01;

  @override
  double get diameterEndRange => .76;

  @override
  double get diameterStartRange => .74;
}

class NickelModel extends CoinModel {
  @override
  String get name => "Nickel";

  @override
  double get amount => .05;

  @override
  double get diameterEndRange => .85;

  @override
  double get diameterStartRange => .83;
}

class DimeModel extends CoinModel {
  @override
  String get name => "Dime";

  @override
  double get amount => .10;

  @override
  double get diameterEndRange => .71;

  @override
  double get diameterStartRange => .69;
}

class QuarterModel extends CoinModel {
  @override
  String get name => "Quarter";

  @override
  double get amount => .25;

  @override
  double get diameterEndRange => .96;

  @override
  double get diameterStartRange => .94;
}
