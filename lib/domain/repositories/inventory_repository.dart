import '../entities/inventory_item.dart';

abstract class InventoryRepository {
  Future<InventoryItem> createInventoryItem(InventoryItem item);
  Future<List<InventoryItem>> getInventoryItems();
  Future<InventoryItem?> getInventoryItemByProductId(String productId);
  Future<void> updateInventoryItem(InventoryItem item);
  Future<void> deleteInventoryItem(String id);
  Future<void> addToInventory(String productId, double quantity);
  Future<void> removeFromInventory(String productId, double quantity);
}
