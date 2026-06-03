class Pet {
  final String id;
  final String name;
  final String species;
  final String breed;
  final int age;
  final String? specialNotes;
  final String ownerId;
  final DateTime createdAt;

  const Pet({
    required this.id,
    required this.name,
    required this.species,
    required this.breed,
    required this.age,
    this.specialNotes,
    required this.ownerId,
    required this.createdAt,
  });

  factory Pet.fromJson(Map<String, dynamic> json) {
    return Pet(
      id: json['id'] as String,
      name: json['name'] as String,
      species: json['species'] as String,
      breed: json['breed'] as String,
      age: json['age'] as int,
      specialNotes: json['specialNotes'] as String?,
      ownerId: json['ownerId'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
    );
  }
}
