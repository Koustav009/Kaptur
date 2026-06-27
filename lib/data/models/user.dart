import 'package:json_annotation/json_annotation.dart';

part 'user.g.dart';

@JsonSerializable()
class User {
  final int? id;

  @JsonKey(name: 'kptId')
  final String? kptId;

  final String name;
  final String email;
  final String? provider;

  @JsonKey(name: 'provider_id')
  final String? providerId;

  @JsonKey(name: 'image_url')
  final String? imageUrl;

  User({
    this.id,
    this.kptId,
    required this.name,
    required this.email,
    this.provider,
    this.providerId,
    this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) => _$UserFromJson(json);
  Map<String, dynamic> toJson() => _$UserToJson(this);
}
