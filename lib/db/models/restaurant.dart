class Restaurant {
  final int id;
  final String nom;
  final String adresse;
  final String telephone;
  final String? photo;
  final String? siret;
  final String? openingHours;
  final bool internetAccess;
  final bool wheelchair;
  final String type;
  final double longitude;
  final double latitude;
  final String? brand;
  final int? capacity;
  final double? stars;
  final String? website;
  final String? map;
  final String? operator;
  final bool vegetarian;
  final bool vegan;
  final bool delivery;
  final bool takeaway;
  final bool driveThrough;
  final String? wikidata;
  final String? brandWikidata;
  final String? facebook;
  final bool smoking;
  final int? idCommune;
  double? distance;

  Restaurant({
    required this.id,
    required this.nom,
    required this.adresse,
    required this.telephone,
    this.photo,
    this.siret,
    this.openingHours,
    required this.internetAccess,
    required this.wheelchair,
    required this.type,
    required this.longitude,
    required this.latitude,
    this.brand,
    this.capacity,
    this.stars,
    this.website,
    this.map,
    this.operator,
    required this.vegetarian,
    required this.vegan,
    required this.delivery,
    required this.takeaway,
    required this.driveThrough,
    this.wikidata,
    this.brandWikidata,
    this.facebook,
    required this.smoking,
    this.idCommune,
    this.distance,
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'] != null
          ? int.tryParse(map['id'].toString()) ?? 0
          : 0, // Gestion sécurisée pour id
      nom: map['nom'] as String? ?? '',
      adresse: map['adresse'] as String? ?? '',
      telephone: map['phone'] as String? ?? '',
      photo: map['photo'] as String?,
      siret: map['siret'] as String?,
      openingHours: map['opening_hours'] as String?,
      internetAccess: map['internet_access'] as bool? ?? false,
      wheelchair: map['wheelchair'] as bool? ?? false,
      type: map['typeR'] as String? ?? '',
      longitude: map['longitude'] != null
          ? double.tryParse(map['longitude'].toString()) ?? 0.0
          : 0.0,
      latitude: map['latitude'] != null
          ? double.tryParse(map['latitude'].toString()) ?? 0.0
          : 0.0,
      brand: map['brand'] as String?,
      capacity: map['capacity'] != null
          ? int.tryParse(map['capacity'].toString())
          : null,
      stars: map['stars'] != null
          ? double.tryParse(map['stars'].toString())
          : null,
      website: map['website'] as String?,
      map: map['map'] as String?,
      operator: map['operator'] as String?,
      vegetarian: map['vegetarian'] as bool? ?? false,
      vegan: map['vegan'] as bool? ?? false,
      delivery: map['delivery'] as bool? ?? false,
      takeaway: map['takeaway'] as bool? ?? false,
      driveThrough: map['drive_through'] as bool? ?? false,
      wikidata: map['wikidata'] as String?,
      brandWikidata: map['brand_wikidata'] as String?,
      facebook: map['facebook'] as String?,
      smoking: map['smoking'] as bool? ?? false,
      idCommune:
          map['idC'] != null ? int.tryParse(map['idC'].toString()) : null,
      distance: null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'nom': nom,
      'adresse': adresse,
      'telephone': telephone,
      'photo': photo,
      'siret': siret,
      'opening_hours': openingHours,
      'internet_access': internetAccess,
      'wheelchair': wheelchair,
      'typeR': type,
      'longitude': longitude,
      'latitude': latitude,
      'brand': brand,
      'capacity': capacity,
      'stars': stars,
      'website': website,
      'map': map,
      'operator': operator,
      'vegetarian': vegetarian,
      'vegan': vegan,
      'delivery': delivery,
      'takeaway': takeaway,
      'drive_through': driveThrough,
      'wikidata': wikidata,
      'brand_wikidata': brandWikidata,
      'facebook': facebook,
      'smoking': smoking,
      'idC': idCommune,
      'distance': distance,
    };
  }

  copyWith({double? distance}) {
    return Restaurant(
      id: id,
      nom: nom,
      adresse: adresse,
      telephone: telephone,
      photo: photo,
      siret: siret,
      openingHours: openingHours,
      internetAccess: internetAccess,
      wheelchair: wheelchair,
      type: type,
      longitude: longitude,
      latitude: latitude,
      brand: brand,
      capacity: capacity,
      stars: stars,
      website: website,
      map: map,
      operator: operator,
      vegetarian: vegetarian,
      vegan: vegan,
      delivery: delivery,
      takeaway: takeaway,
      driveThrough: driveThrough,
      wikidata: wikidata,
      brandWikidata: brandWikidata,
      facebook: facebook,
      smoking: smoking,
      idCommune: idCommune ?? this.idCommune, // Conserver la valeur d'origine
      distance:
          distance ?? this.distance, // Mettre à jour la distance si fournie
    );
  }
}
