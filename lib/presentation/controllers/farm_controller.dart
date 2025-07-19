import 'package:fiap_farms/domain/entities/farm.dart';
import 'package:fiap_farms/domain/usecases/farm_usecases.dart';
import 'package:flutter/material.dart';

class FarmController extends ChangeNotifier {
  final GetFarmsUseCase _getFarmsUseCase;
  final GetTotalProductionUseCase _getTotalProductionUseCase;
  final CreateFarmUseCase _createFarmUseCase; // Adicionado
  
  List<Farm> _farms = [];
  bool _isLoading = false;
  String _errorMessage = '';
  double _totalProduction = 0;

  List<Farm> get farms => _farms;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;
  double get totalProduction => _totalProduction;

  FarmController({
    required GetFarmsUseCase getFarmsUseCase,
    required GetTotalProductionUseCase getTotalProductionUseCase,
    required CreateFarmUseCase createFarmUseCase, // Adicionado
  }) : _getFarmsUseCase = getFarmsUseCase,
       _getTotalProductionUseCase = getTotalProductionUseCase,
       _createFarmUseCase = createFarmUseCase; // Inicializado

  Future<void> initializeFarms() async {
    _setLoading(true);
    _clearError();
    try {
      await _loadFarms();
      await _loadTotalProduction();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> createFarm(Farm farm) async {
    _setLoading(true);
    _clearError();
    try {
      await _createFarmUseCase.execute(farm);
      await _loadFarms(); // Atualiza a lista após criação
      await _loadTotalProduction(); // Atualiza a produção total
    } catch (e) {
      _setError(e.toString());
      rethrow;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadFarms() async {
    _farms = await _getFarmsUseCase.execute();
    notifyListeners();
  }

  Future<void> _loadTotalProduction() async {
    _totalProduction = await _getTotalProductionUseCase.execute();
    notifyListeners();
  }

  Future<void> reloadFarms() async {
    await _loadFarms();
    await _loadTotalProduction();
  }

  void _setLoading(bool loading) {
    if (_isLoading != loading) {
      _isLoading = loading;
      notifyListeners();
    }
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