class Restaurant {
  final int id;
  final String name;
  final String description;
  final String imageUrl;

  Restaurant({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    return Restaurant(
      id: json['id'],
      name: json['name'],
      description: json['description'],
      imageUrl: json['image_url'],
    );
  }
}