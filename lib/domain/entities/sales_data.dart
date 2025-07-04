class SalesData {
  final double totalSales;
  final double totalProfit;
  final int orders;
  final double growth;
  final List<ProductData> products;

  SalesData({
    required this.totalSales,
    required this.totalProfit,
    required this.orders,
    required this.growth,
    required this.products,
  });
}

class ProductData {
  final String name;
  final double profit;

  ProductData({required this.name, required this.profit});
}
