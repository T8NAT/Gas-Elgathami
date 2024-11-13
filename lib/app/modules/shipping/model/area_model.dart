class Area {
  final int id;
  final String areaName;
  final double price;

  Area({required this.id, required this.areaName, required this.price});

  factory Area.fromJson(Map<String, dynamic> json) {
    return Area(
      id: json['id'],
      areaName: json['area_name'],
      price: json['price'].toDouble(),
    );
  }
}