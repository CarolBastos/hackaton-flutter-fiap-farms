import '../entities/product.dart';

abstract class ProductRepository {
  Future<Product> createProduct(Product product);
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(String id);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(String id);
}
