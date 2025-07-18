import 'package:fiap_farms/domain/entities/farm.dart';
import 'package:fiap_farms/domain/repositories/farm_repository.dart';

class GetFarmsUseCase {
  final FarmRepository repository;

  GetFarmsUseCase(this.repository);

  Future<List<Farm>> execute() => repository.getFarms();
}

class GetFarmByIdUseCase {
  final FarmRepository repository;

  GetFarmByIdUseCase(this.repository);

  Future<Farm> execute(String id) => repository.getFarmById(id);
}

class CreateFarmUseCase {
  final FarmRepository repository;

  CreateFarmUseCase(this.repository);

  Future<Farm> execute(Farm farm) => repository.createFarm(farm);
}

class UpdateFarmUseCase {
  final FarmRepository repository;

  UpdateFarmUseCase(this.repository);

  Future<void> execute(Farm farm) => repository.updateFarm(farm);
}

class DeleteFarmUseCase {
  final FarmRepository repository;

  DeleteFarmUseCase(this.repository);

  Future<void> execute(String id) => repository.deleteFarm(id);
}

class GetTotalProductionUseCase {
  final FarmRepository repository;

  GetTotalProductionUseCase(this.repository);

  Future<double> execute() => repository.getTotalAnnualProduction();
}
