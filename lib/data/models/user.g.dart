// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

User _$UserFromJson(Map<String, dynamic> json) => User(
  id: (json['id'] as num?)?.toInt(),
  kptId: json['kptId'] as String?,
  name: json['name'] as String,
  email: json['email'] as String,
  provider: json['provider'] as String?,
  providerId: json['provider_id'] as String?,
  imageUrl: json['image_url'] as String?,
);

Map<String, dynamic> _$UserToJson(User instance) => <String, dynamic>{
  'id': instance.id,
  'kptId': instance.kptId,
  'name': instance.name,
  'email': instance.email,
  'provider': instance.provider,
  'provider_id': instance.providerId,
  'image_url': instance.imageUrl,
};
