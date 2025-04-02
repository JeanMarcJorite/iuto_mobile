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
  final double? longitude;
  final double? latitude;
  final String? brand;
  final String? capacity; // Modifié en String?
  final String? stars; // Modifié en String?
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
    required this.stars,
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
  });

  factory Restaurant.fromMap(Map<String, dynamic> map) {
    return Restaurant(
      id: map['id'] as int,
      nom: map['nom'] as String,
      adresse: map['adresse'] as String,
      telephone: map['phone'] as String,
      photo: map['photo'] as String?,
      siret: map['siret'] as String?,
      openingHours: map['opening_hours'] as String?,
      internetAccess: map['internet_access'] as bool,
      wheelchair: map['wheelchair'] as bool,
      type: map['typeR'] as String,
      longitude: map['longitude'] as double?,
      latitude: map['latitude'] as double?,
      brand: map['brand'] as String?,
      capacity: map['capacity'] as String?, // Modifié
      stars: map['stars'] as String?, // Modifié
      website: map['website'] as String?,
      map: map['map'] as String?,
      operator: map['operator'] as String?,
      vegetarian: map['vegetarian'] as bool,
      vegan: map['vegan'] as bool,
      delivery: map['delivery'] as bool,
      takeaway: map['takeaway'] as bool,
      driveThrough: map['drive_through'] as bool,
      wikidata: map['wikidata'] as String?,
      brandWikidata: map['brand_wikidata'] as String?,
      facebook: map['facebook'] as String?,
      smoking: map['smoking'] as bool,
      idCommune: map['idC'] as int?,
    );
  }
}
