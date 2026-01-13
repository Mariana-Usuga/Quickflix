import 'package:quickflix/shared/entities/profile.dart';

class ProfileModel extends Profile {
  const ProfileModel({
    required super.id,
    required super.createdAt,
    required super.coins,
    super.photoProfile,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    // Parsear created_at
    DateTime? createdAt;
    if (json['created_at'] != null) {
      if (json['created_at'] is String) {
        createdAt = DateTime.tryParse(json['created_at']);
      } else if (json['created_at'] is DateTime) {
        createdAt = json['created_at'] as DateTime;
      }
    }
    createdAt ??= DateTime.now();

    return ProfileModel(
      id: json['id'] as String? ?? '',
      createdAt: createdAt,
      coins: json['coins'] as int? ?? 0,
      photoProfile: json['photo_profile'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'created_at': createdAt.toIso8601String(),
        'coins': coins,
        'photo_profile': photoProfile,
      };
}
