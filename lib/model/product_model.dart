abstract class Product {
  double get price;
  String get name;
}

class Chips extends Product {
  @override
  String get name => "Chips";

  @override
  double get price => 0.50;
}

class Cola extends Product {
  @override
  String get name => "Cola";

  @override
  double get price => 1;
}

class Candy extends Product {
  @override
  String get name => "Candy";

  @override
  double get price => 0.65;
}