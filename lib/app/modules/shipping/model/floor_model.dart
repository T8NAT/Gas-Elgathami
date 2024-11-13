class Floor {
  final int id;
  final String floorName;
  final double price;

  Floor({required this.id, required this.floorName, required this.price});

  factory Floor.fromJson(Map<String, dynamic> json) {
    return Floor(
      id: json['id'],
      floorName: json['floor_name'],
      price: json['price'].toDouble(),
    );
  }
}