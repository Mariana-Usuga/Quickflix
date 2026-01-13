class Profile {
  final String id; // UUID
  final DateTime createdAt;
  final int coins;
  final String? photoProfile;

  const Profile({
    required this.id,
    required this.createdAt,
    required this.coins,
    this.photoProfile,
  });
}
