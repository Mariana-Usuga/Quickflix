class UserEntity {
  final String id;
  final String email;
  final String? planType;

  const UserEntity({required this.id, required this.email, this.planType});
}
