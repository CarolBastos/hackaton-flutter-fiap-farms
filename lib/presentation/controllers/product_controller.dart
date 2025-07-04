import 'package:flutter/material.dart';
import '../../domain/entities/product.dart';
import '../../domain/usecases/product_usecases.dart';

class ProductController extends ChangeNotifier {
  final CreateProductUseCase _createProductUseCase;
  final GetProductsUseCase _getProductsUseCase;

  ProductController({
    required CreateProductUseCase createProductUseCase,
    required GetProductsUseCase getProductsUseCase,
  }) : _createProductUseCase = createProductUseCase,
       _getProductsUseCase = getProductsUseCase;

  List<Product> _products = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<Product> get products => _products;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> createProduct(Product product) async {
    _setLoading(true);
    _clearError();

    try {
      final newProduct = await _createProductUseCase.execute(product);
      _products.insert(0, newProduct);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadProducts() async {
    print('ProductController: Iniciando carregamento de produtos');
    _setLoading(true);
    _clearError();

    try {
      _products = await _getProductsUseCase.execute();
      print('ProductController: Produtos carregados: ${_products.length}');
      notifyListeners();
    } catch (e) {
      print('ProductController: Erro ao carregar produtos: $e');
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _errorMessage = error;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = '';
    notifyListeners();
  }
}
