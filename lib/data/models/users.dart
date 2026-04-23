class User {
  final int id;
  final String name;
  final String email;
  final String? provider;
  final String? providerId;
  final String? imageUrl;

  User({
    required this.id,
    required this.name,
    required this.email,
    this.provider,
    this.providerId,
    this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      provider: json['provider'],
      providerId: json['provider_id'],
      imageUrl: json['image_url'],
    );
  }
}
