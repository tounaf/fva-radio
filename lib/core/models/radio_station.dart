class RadioStation {
  final String id;
  final String name;
  final double frequency;
  final String logoUrl;
  final String streamUrl;
  final String genre;
  final String description;
  final bool isFavorite;

  RadioStation({
    required this.id,
    required this.name,
    required this.frequency,
    required this.logoUrl,
    required this.streamUrl,
    required this.genre,
    this.description = '',
    this.isFavorite = false,
  });

  // Station par défaut pour 94.2
  static RadioStation defaultStation() {
    return RadioStation(
      id: 'default',
      name: 'NRJ',
      frequency: 94.2,
      logoUrl: 'assets/logos/nrj.png',
      streamUrl: 'https://stream.nrj.fr/nrj',
      genre: 'Pop / Dance',
      description: 'La meilleure musique pop et dance',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'frequency': frequency,
    'logoUrl': logoUrl,
    'streamUrl': streamUrl,
    'genre': genre,
    'description': description,
    'isFavorite': isFavorite,
  };

  factory RadioStation.fromJson(Map<String, dynamic> json) {
    return RadioStation(
      id: json['id'],
      name: json['name'],
      frequency: json['frequency'],
      logoUrl: json['logoUrl'],
      streamUrl: json['streamUrl'],
      genre: json['genre'],
      description: json['description'] ?? '',
      isFavorite: json['isFavorite'] ?? false,
    );
  }

  RadioStation copyWith({
    String? id,
    String? name,
    double? frequency,
    String? logoUrl,
    String? streamUrl,
    String? genre,
    String? description,
    bool? isFavorite,
  }) {
    return RadioStation(
      id: id ?? this.id,
      name: name ?? this.name,
      frequency: frequency ?? this.frequency,
      logoUrl: logoUrl ?? this.logoUrl,
      streamUrl: streamUrl ?? this.streamUrl,
      genre: genre ?? this.genre,
      description: description ?? this.description,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}