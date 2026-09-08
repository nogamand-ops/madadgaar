enum VehicleType { motorcycle, car, suv, van, truck }

VehicleType vehicleTypeFromString(String value) => VehicleType.values.firstWhere(
      (v) => v.name == value,
      orElse: () => VehicleType.car,
    );

extension VehicleTypeLabel on VehicleType {
  String get label => switch (this) {
        VehicleType.motorcycle => 'Motorcycle',
        VehicleType.car => 'Car',
        VehicleType.suv => 'SUV',
        VehicleType.van => 'Van',
        VehicleType.truck => 'Truck',
      };

  String get emoji => switch (this) {
        VehicleType.motorcycle => '🏍️',
        VehicleType.car => '🚗',
        VehicleType.suv => '🚙',
        VehicleType.van => '🚐',
        VehicleType.truck => '🚚',
      };
}

class Vehicle {
  final String id;
  final String customerId;
  final VehicleType type;
  final String make;
  final String model;
  final int? year;
  final String fuelType;
  final String? nickname;

  const Vehicle({
    required this.id,
    required this.customerId,
    required this.type,
    required this.make,
    required this.model,
    required this.fuelType,
    this.year,
    this.nickname,
  });

  String get displayName => nickname?.isNotEmpty == true ? nickname! : '$make $model';

  factory Vehicle.fromJson(Map<String, dynamic> json) => Vehicle(
        id: json['id'] as String,
        customerId: json['customerId'] as String,
        type: vehicleTypeFromString(json['type'] as String),
        make: json['make'] as String,
        model: json['model'] as String,
        year: json['year'] as int?,
        fuelType: json['fuelType'] as String? ?? 'petrol',
        nickname: json['nickname'] as String?,
      );

  Map<String, dynamic> toJson() => {
        'type': type.name,
        'make': make,
        'model': model,
        'year': year,
        'fuelType': fuelType,
        'nickname': nickname,
      };
}
