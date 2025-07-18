import 'package:fiap_farms/domain/entities/farm.dart';

abstract class FarmRepository {
  Future<List<Farm>> getFarms();
  Future<Farm> getFarmById(String id);
  Future<Farm> createFarm(Farm farm);
  Future<void> deleteFarm(String id);
  Future<void> updateFarm(Farm farm);
  Future<double> getTotalAnnualProduction();
}
