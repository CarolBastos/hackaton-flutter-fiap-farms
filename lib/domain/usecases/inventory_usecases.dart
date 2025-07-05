import '../entities/inventory_item.dart';
import '../repositories/inventory_repository.dart';

class CreateInventoryItemUseCase {
  final InventoryRepository repository;

  CreateInventoryItemUseCase(this.repository);

  Future<InventoryItem> execute(InventoryItem item) {
    if (item.productId.isEmpty) {
      throw Exception('ID do produto é obrigatório');
    }
    if (item.availableQuantity < 0) {
      throw Exception('Quantidade disponível não pode ser negativa');
    }

    return repository.createInventoryItem(item);
  }
}

class GetInventoryItemsUseCase {
  final InventoryRepository repository;

  GetInventoryItemsUseCase(this.repository);

  Future<List<InventoryItem>> execute() {
    return repository.getInventoryItems();
  }
}

class GetInventoryItemByProductIdUseCase {
  final InventoryRepository repository;

  GetInventoryItemByProductIdUseCase(this.repository);

  Future<InventoryItem?> execute(String productId) {
    if (productId.isEmpty) {
      throw Exception('ID do produto é obrigatório');
    }

    return repository.getInventoryItemByProductId(productId);
  }
}

class UpdateInventoryItemUseCase {
  final InventoryRepository repository;

  UpdateInventoryItemUseCase(this.repository);

  Future<void> execute(InventoryItem item) {
    if (item.id == null) {
      throw Exception('ID do item de inventário é obrigatório');
    }
    if (item.availableQuantity < 0) {
      throw Exception('Quantidade disponível não pode ser negativa');
    }

    return repository.updateInventoryItem(item);
  }
}

class AddToInventoryUseCase {
  final InventoryRepository repository;

  AddToInventoryUseCase(this.repository);

  Future<void> execute(String productId, double quantity) {
    if (productId.isEmpty) {
      throw Exception('ID do produto é obrigatório');
    }
    if (quantity <= 0) {
      throw Exception('Quantidade deve ser maior que zero');
    }

    return repository.addToInventory(productId, quantity);
  }
}

class RemoveFromInventoryUseCase {
  final InventoryRepository repository;

  RemoveFromInventoryUseCase(this.repository);

  Future<void> execute(String productId, double quantity) {
    if (productId.isEmpty) {
      throw Exception('ID do produto é obrigatório');
    }
    if (quantity <= 0) {
      throw Exception('Quantidade deve ser maior que zero');
    }

    return repository.removeFromInventory(productId, quantity);
  }
}
