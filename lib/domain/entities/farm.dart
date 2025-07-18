class Farm {
  final String id;
  final String name;
  final String productType;
  final double annualProduction;
  final Location location; // Nova classe de localização
  final String? address;
  final double? area;
  final DateTime? establishedDate;

  Farm({
    required this.id,
    required this.name,
    required this.productType,
    required this.annualProduction,
    required this.location,
    this.address,
    this.area,
    this.establishedDate,
  });

  // Método para gerar URL do mapa estático
  String get staticMapUrl {
    return 'https://maps.googleapis.com/maps/api/staticmap?'
        'center=${location.latitude},${location.longitude}'
        '&zoom=15'
        '&size=300x200'
        '&maptype=terrain'
        '&markers=color:red%7C${location.latitude},${location.longitude}'
        '&key=SUA_CHAVE_DE_API'; // Substitua pela sua chave
  }

  Farm copyWith({
    String? id,
    String? name,
    String? productType,
    double? annualProduction,
    Location? location,
    String? address,
    double? area,
    DateTime? establishedDate,
  }) {
    return Farm(
      id: id ?? this.id,
      name: name ?? this.name,
      productType: productType ?? this.productType,
      annualProduction: annualProduction ?? this.annualProduction,
      address: address ?? this.address,
      area: area ?? this.area,
      establishedDate: establishedDate ?? this.establishedDate, 
      location: location ?? this.location,
    );
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});
}