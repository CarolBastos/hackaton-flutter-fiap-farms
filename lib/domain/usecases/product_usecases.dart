import '../entities/product.dart';
import '../repositories/product_repository.dart';

class CreateProductUseCase {
  final ProductRepository repository;

  CreateProductUseCase(this.repository);

  Future<Product> execute(Product product) {
    if (product.name.isEmpty) {
      throw Exception('Nome do produto é obrigatório');
    }
    if (product.category.isEmpty) {
      throw Exception('Categoria é obrigatória');
    }
    if (product.unitOfMeasure.isEmpty) {
      throw Exception('Unidade de medida é obrigatória');
    }
    if (product.estimatedCostPerUnit <= 0) {
      throw Exception('Custo estimado deve ser maior que zero');
    }

    return repository.createProduct(product);
  }
}

class GetProductsUseCase {
  final ProductRepository repository;

  GetProductsUseCase(this.repository);

  Future<List<Product>> execute() {
    return repository.getProducts();
  }
}

class GetProductByIdUseCase {
  final ProductRepository repository;

  GetProductByIdUseCase(this.repository);

  Future<Product?> execute(String id) {
    if (id.isEmpty) {
      throw Exception('ID do produto é obrigatório');
    }

    return repository.getProductById(id);
  }
}
