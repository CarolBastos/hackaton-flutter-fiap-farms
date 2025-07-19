import 'package:flutter/material.dart';
import '../../domain/entities/inventory_item.dart';
import '../../domain/usecases/inventory_usecases.dart';
import '../../domain/usecases/goals_usecases.dart';

class InventoryController extends ChangeNotifier {
  final CreateInventoryItemUseCase _createInventoryItemUseCase;
  final GetInventoryItemsUseCase _getInventoryItemsUseCase;
  final GetInventoryItemByProductIdUseCase _getInventoryItemByProductIdUseCase;
  final UpdateInventoryItemUseCase _updateInventoryItemUseCase;
  final AddToInventoryUseCase _addToInventoryUseCase;
  final RemoveFromInventoryUseCase _removeFromInventoryUseCase;

  final GetGoalsByStatusUseCase _getGoalsByStatusUseCase;
  final UpdateGoalProgressUseCase _updateGoalProgressUseCase;
  final CompleteGoalUseCase _completeGoalUseCase;

  final BuildContext context;

  InventoryController({
    required this.context,
    required CreateInventoryItemUseCase createInventoryItemUseCase,
    required GetInventoryItemsUseCase getInventoryItemsUseCase,
    required GetInventoryItemByProductIdUseCase
    getInventoryItemByProductIdUseCase,
    required UpdateInventoryItemUseCase updateInventoryItemUseCase,
    required AddToInventoryUseCase addToInventoryUseCase,
    required RemoveFromInventoryUseCase removeFromInventoryUseCase,
    required GetGoalsByStatusUseCase getGoalsByStatusUseCase,
    required UpdateGoalProgressUseCase updateGoalProgressUseCase,
    required CompleteGoalUseCase completeGoalUseCase,
    required GetActiveGoalsUseCase getActiveGoalsUseCase,
  }) : _createInventoryItemUseCase = createInventoryItemUseCase,
       _getInventoryItemsUseCase = getInventoryItemsUseCase,
       _getInventoryItemByProductIdUseCase = getInventoryItemByProductIdUseCase,
       _updateInventoryItemUseCase = updateInventoryItemUseCase,
       _addToInventoryUseCase = addToInventoryUseCase,
       _removeFromInventoryUseCase = removeFromInventoryUseCase,
       _getGoalsByStatusUseCase = getGoalsByStatusUseCase,
       _updateGoalProgressUseCase = updateGoalProgressUseCase,
       _completeGoalUseCase = completeGoalUseCase;

  List<InventoryItem> _inventoryItems = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<InventoryItem> get inventoryItems => _inventoryItems;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  String? lastAchievedGoalName;

  Future<void> addToInventory(String productId, double quantity) async {
    _setLoading(true);
    _clearError();
    lastAchievedGoalName = null;

    try {
      await _addToInventoryUseCase.execute(productId, quantity);
      await loadInventoryItems();
      await _updateGoalProgress(quantity, 'producao');
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _updateGoalProgress(double increment, String type) async {
    final activeGoals = await _getGoalsByStatusUseCase.execute('ativa');

    for (final goal in activeGoals.where((g) => g.type == type)) {
      final newValue = goal.currentValue + increment;
      await _updateGoalProgressUseCase.execute(goal.id!, newValue);

      if (newValue >= goal.targetValue) {
        await _completeGoalUseCase.execute(goal.id!);
        lastAchievedGoalName = goal.name;
      }
    }

    notifyListeners(); // Notifica UI para mostrar pop-up, se necessário
  }

  void clearLastAchievedGoalName() {
    lastAchievedGoalName = null;
    notifyListeners();
  }

  Future<void> createInventoryItem(InventoryItem item) async {
    _setLoading(true);
    _clearError();

    try {
      final newItem = await _createInventoryItemUseCase.execute(item);
      _inventoryItems.insert(0, newItem);
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadInventoryItems() async {
    _setLoading(true);
    _clearError();

    try {
      _inventoryItems = await _getInventoryItemsUseCase.execute();
      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<InventoryItem?> getInventoryItemByProductId(String productId) async {
    try {
      return await _getInventoryItemByProductIdUseCase.execute(productId);
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<void> updateInventoryItem(InventoryItem item) async {
    _setLoading(true);
    _clearError();

    try {
      await _updateInventoryItemUseCase.execute(item);
      final index = _inventoryItems.indexWhere(
        (inventoryItem) => inventoryItem.id == item.id,
      );
      if (index != -1) {
        _inventoryItems[index] = item;
        notifyListeners();
      }
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> removeFromInventory(String productId, double quantity) async {
    _setLoading(true);
    _clearError();

    try {
      await _removeFromInventoryUseCase.execute(productId, quantity);
      await loadInventoryItems(); // Recarregar para refletir mudanças
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  /// Processa uma venda, subtraindo do estoque disponível e adicionando à quantidade vendida
  Future<void> processSale(String productId, double quantity) async {
    _setLoading(true);
    _clearError();

    try {
      // Primeiro, verifica se há estoque suficiente
      final inventoryItem = await getInventoryItemByProductId(productId);
      if (inventoryItem == null) {
        throw Exception('Produto não encontrado no estoque');
      }

      if (inventoryItem.availableQuantity < quantity) {
        throw Exception(
          'Estoque insuficiente. Disponível: ${inventoryItem.availableQuantity} ${inventoryItem.unitOfMeasure}',
        );
      }

      // Calcula as novas quantidades
      final newAvailableQuantity = inventoryItem.availableQuantity - quantity;
      final newSoldQuantity = inventoryItem.soldQuantity + quantity;

      // Atualiza o item com as novas quantidades
      final updatedItem = inventoryItem.copyWith(
        availableQuantity: newAvailableQuantity,
        soldQuantity: newSoldQuantity,
        lastUpdated: DateTime.now(),
      );

      // Salva as mudanças no banco de dados
      await _updateInventoryItemUseCase.execute(updatedItem);

      // Atualiza a lista local
      final index = _inventoryItems.indexWhere(
        (item) => item.id == updatedItem.id,
      );
      if (index != -1) {
        _inventoryItems[index] = updatedItem;
      }

      notifyListeners();
    } catch (e) {
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
